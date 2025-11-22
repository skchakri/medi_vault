# frozen_string_literal: true

module Admin
  class WorkflowsController < AdminController
    before_action :set_workflow, only: %i[show update]

    def index
      @workflows = Workflow.order(:name)
      @tool_specs = AiTools::REGISTRY
    end

    def show
      render json: @workflow
    end

    def new
      @workflow = Workflow.new
      @tool_specs = AiTools::REGISTRY
    end

    def create
      @workflow = Workflow.new(workflow_params.merge(created_by: current_user))
      if @workflow.save
        respond_to do |format|
          format.html { redirect_to admin_workflows_path, notice: 'Workflow created.' }
          format.json { render json: @workflow, status: :created }
        end
      else
        load_collections
        respond_to do |format|
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def update
      if @workflow.update(workflow_params)
        respond_to do |format|
          format.html { redirect_to admin_workflows_path, notice: 'Workflow updated.' }
          format.json { render json: @workflow, status: :ok }
        end
      else
        load_collections
        respond_to do |format|
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_workflow
      @workflow = Workflow.find(params[:id])
    end

    def workflow_params
      params.require(:workflow).permit(
        :name,
        :description,
        :status,
        { nodes: [:uid, :id, :tool_key, :name, :description, { config: {}, ui: {} }] },
        { edges: [:from, :to] }
      )
    end

    def load_collections
      @workflows = Workflow.order(:name)
      @tool_specs = AiTools::REGISTRY
    end
  end
end
