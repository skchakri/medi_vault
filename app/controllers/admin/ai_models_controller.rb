# frozen_string_literal: true

module Admin
  class AiModelsController < AdminController
    before_action :set_ai_model, only: %i[edit update destroy set_default]

    def index
      @ai_models = AiModel.order(is_default: :desc, created_at: :desc)
    end

    def new
      @ai_model = AiModel.new
    end

    def create
      @ai_model = AiModel.new(ai_model_params)
      if @ai_model.save
        redirect_to admin_ai_models_path, notice: 'AI Model was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @ai_model.update(ai_model_params)
        redirect_to admin_ai_models_path, notice: 'AI Model was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @ai_model.is_default?
        redirect_to admin_ai_models_path, alert: 'Cannot delete the default AI model.'
      else
        @ai_model.destroy
        redirect_to admin_ai_models_path, notice: 'AI Model was successfully deleted.'
      end
    end

    def set_default
      @ai_model.update!(is_default: true)
      redirect_to admin_ai_models_path, notice: "#{@ai_model.name} is now the default AI model."
    end

    private

    def set_ai_model
      @ai_model = AiModel.find(params[:id])
    end

    def ai_model_params
      params.require(:ai_model).permit(:name, :provider, :model_identifier, :is_default, :active)
    end
  end
end
