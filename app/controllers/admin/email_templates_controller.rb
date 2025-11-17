# frozen_string_literal: true

module Admin
  class EmailTemplatesController < AdminController
    before_action :set_email_template, only: [:show, :edit, :update, :destroy]

    def index
      @email_templates = EmailTemplate.order(template_type: :asc)
    end

    def show
    end

    def new
      @email_template = EmailTemplate.new
    end

    def edit
    end

    def create
      @email_template = EmailTemplate.new(email_template_params)

      if @email_template.save
        redirect_to admin_email_template_path(@email_template), notice: "Email template was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @email_template.update(email_template_params)
        redirect_to admin_email_template_path(@email_template), notice: "Email template was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @email_template.destroy
      redirect_to admin_email_templates_path, notice: "Email template was successfully deleted."
    end

    private

    def set_email_template
      @email_template = EmailTemplate.find(params[:id])
    end

    def email_template_params
      params.require(:email_template).permit(:name, :template_type, :subject, :html_body, :text_body, :sms_body, :active, variables: {})
    end
  end
end
