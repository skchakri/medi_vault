# frozen_string_literal: true

module Admin
  class TagsController < AdminController
    before_action :set_tag, only: [:edit, :update, :destroy]

    def index
      @tags = Tag.default_tags.alphabetical
    end

    def new
      @tag = Tag.new(is_default: true, active: true)
    end

    def create
      @tag = Tag.new(tag_params)
      @tag.is_default = true

      if @tag.save
        flash[:notice] = "Tag created successfully."
        redirect_to admin_tags_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @tag.update(tag_params)
        flash[:notice] = "Tag updated successfully."
        redirect_to admin_tags_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @tag.credentials.any?
        flash[:alert] = "Cannot delete tag that is currently in use by #{@tag.credentials.count} credential(s)."
        redirect_to admin_tags_path
      else
        @tag.destroy
        flash[:notice] = "Tag deleted successfully."
        redirect_to admin_tags_path
      end
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :color, :description, :active)
    end
  end
end
