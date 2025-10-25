module Api
  module V1
    class ProjectsController < Api::BaseController
      def index
        @projects = Project.includes(:team, :epics, :stories).all
      end

      def show
        @project = Project.includes(:team, :epics, stories: :assignee).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      def create
        @project = Project.new(project_params)
        if @project.save
          render :create, status: :created
        else
          render json: { errors: @project.errors }, status: :unprocessable_entity
        end
      end

      def update
        @project = Project.find(params[:id])
        if @project.update(project_params)
          render :show
        else
          render json: { errors: @project.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      def destroy
        @project = Project.find(params[:id])
        @project.destroy
        render json: { message: "Project deleted" }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      private

      def project_params
        params.require(:project).permit(:name, :description, :team_id, :organization_id)
      end
    end
  end
end
