# frozen_string_literal: true

require 'prawn'
require 'prawn/table'

class CredentialPdfBundler
  def initialize(credentials)
    @credentials = credentials
  end

  def bundle
    temp_file = Tempfile.new(['credentials_bundle', '.pdf'])

    Prawn::Document.generate(temp_file.path, page_size: 'LETTER') do |pdf|
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

    temp_file.path
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

  def number_to_human_size(bytes)
    return '0 B' if bytes.zero?

    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.length - 1 if exp >= units.length

    "%.2f %s" % [bytes.to_f / 1024**exp, units[exp]]
  end
end
