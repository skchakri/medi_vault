# frozen_string_literal: true

require 'prawn'
require 'prawn/table'
require 'combine_pdf'

class CredentialPdfBundler
  def initialize(credentials)
    @credentials = credentials
  end

  def bundle
    # Generate summary PDF
    summary_file = Tempfile.new(['credentials_summary', '.pdf'])

    Prawn::Document.generate(summary_file.path, page_size: 'LETTER') do |pdf|
      pdf.font_size 10

      # Cover page
      generate_cover_page(pdf)

      # Table of contents
      generate_table_of_contents(pdf)

      # Individual credential pages
      @credentials.each_with_index do |credential, index|
        pdf.start_new_page unless index == 0 && pdf.page_number == 2
        generate_credential_page(pdf, credential, index + 1)
      end
    end

    # Merge with actual credential files
    final_pdf = merge_with_credential_files(summary_file.path)

    final_file = Tempfile.new(['credentials_bundle', '.pdf'])
    final_pdf.save(final_file.path)

    summary_file.close
    summary_file.unlink

    final_file.path
  end

  private

  def generate_cover_page(pdf)
    pdf.move_down 100
    pdf.text "Medical Credentials Bundle", size: 24, style: :bold, align: :center
    pdf.move_down 20
    pdf.text "Generated on #{Date.today.strftime('%B %d, %Y')}", size: 12, align: :center
    pdf.move_down 20
    pdf.text "Total Credentials: #{@credentials.count}", size: 14, align: :center
  end

  def generate_table_of_contents(pdf)
    pdf.start_new_page
    pdf.text "Table of Contents", size: 18, style: :bold
    pdf.move_down 20

    data = [["#", "Credential Title", "Expiry Date", "Status"]]

    @credentials.each_with_index do |cred, index|
      data << [
        (index + 1).to_s,
        cred.title,
        cred.end_date&.strftime('%m/%d/%Y') || 'N/A',
        cred.status.titleize
      ]
    end

    pdf.table(data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      columns(0).align = :center
      columns(2..3).align = :center
    end
  end

  def generate_credential_page(pdf, credential, number)
    pdf.text "Credential ##{number}", size: 16, style: :bold
    pdf.move_down 10

    # Credential details table
    data = [
      ["Title", credential.title],
      ["Status", credential.status.titleize],
      ["Issue Date", credential.start_date&.strftime('%B %d, %Y') || 'N/A'],
      ["Expiry Date", credential.end_date&.strftime('%B %d, %Y') || 'N/A']
    ]

    if credential.issuing_organization.present?
      data << ["Issued by", credential.issuing_organization]
    end

    if credential.credential_number.present?
      data << ["Credential Number", credential.credential_number]
    end

    if credential.document_summary.present?
      data << ["Summary", credential.document_summary]
    end

    if credential.notes.present?
      data << ["Notes", credential.notes]
    end

    pdf.table(data, width: pdf.bounds.width, cell_style: { padding: 8 }) do
      columns(0).font_style = :bold
      columns(0).background_color = 'EEEEEE'
      columns(0).width = 150
    end

    # Tags
    if credential.tags.any?
      pdf.move_down 15
      pdf.text "Tags: #{credential.tags.pluck(:name).join(', ')}", size: 10, style: :italic
    end

    # File information
    if credential.file.attached?
      pdf.move_down 15
      pdf.text "Attached File: #{credential.file.filename} (#{number_to_human_size(credential.file.byte_size)})",
               size: 10
      pdf.text "Note: Original files are available separately upon request.", size: 8, style: :italic
    end
  end

  def merge_with_credential_files(summary_path)
    combined_pdf = CombinePDF.load(summary_path)

    @credentials.each_with_index do |credential, index|
      next unless credential.file.attached?

      begin
        # Download the file to a temporary location
        temp_file = Tempfile.new(["credential_#{index}", File.extname(credential.file.filename.to_s)])
        temp_file.binmode
        credential.file.download { |chunk| temp_file.write(chunk) }
        temp_file.rewind

        content_type = credential.file.content_type

        if content_type == "application/pdf"
          # If it's a PDF, merge it directly
          credential_pdf = CombinePDF.load(temp_file.path)

          # Add a separator page before each credential file
          separator_page = create_separator_page(credential, index + 1)
          combined_pdf << separator_page

          # Add all pages from the credential PDF
          credential_pdf.pages.each { |page| combined_pdf << page }
        elsif content_type&.start_with?("image/")
          # If it's an image, create a PDF page with the image
          separator_page = create_separator_page(credential, index + 1)
          combined_pdf << separator_page

          image_page = create_image_page(temp_file.path, credential)
          combined_pdf << CombinePDF.load(image_page)
        end

        temp_file.close
        temp_file.unlink
      rescue => e
        Rails.logger.error("Failed to attach file for credential #{credential.id}: #{e.message}")
        # Continue with other files even if one fails
      end
    end

    combined_pdf
  end

  def create_separator_page(credential, number)
    separator_file = Tempfile.new(["separator_#{number}", ".pdf"])

    Prawn::Document.generate(separator_file.path, page_size: "LETTER") do |pdf|
      pdf.move_down 250
      pdf.text "Credential ##{number} - Original Document", size: 20, style: :bold, align: :center
      pdf.move_down 20
      pdf.text credential.title, size: 16, align: :center
      pdf.move_down 10
      pdf.text "The following pages contain the original credential document",
               size: 12, align: :center, color: "666666"
    end

    CombinePDF.load(separator_file.path).pages[0]
  ensure
    separator_file&.close
    separator_file&.unlink
  end

  def create_image_page(image_path, credential)
    image_pdf_file = Tempfile.new(["image_page", ".pdf"])

    Prawn::Document.generate(image_pdf_file.path, page_size: "LETTER") do |pdf|
      # Calculate dimensions to fit the image on the page
      page_width = pdf.bounds.width
      page_height = pdf.bounds.height

      # Try to fit the image maintaining aspect ratio
      begin
        pdf.image image_path,
                  fit: [page_width, page_height],
                  position: :center,
                  vposition: :center
      rescue => e
        # If image embedding fails, show an error message
        pdf.text "Unable to display image: #{e.message}", size: 12, color: "CC0000"
      end
    end

    image_pdf_file.path
  ensure
    image_pdf_file&.close unless image_pdf_file&.closed?
  end

  def number_to_human_size(bytes)
    return "0 B" if bytes.zero?

    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.length - 1 if exp >= units.length

    "%.2f %s" % [bytes.to_f / 1024**exp, units[exp]]
  end
end
