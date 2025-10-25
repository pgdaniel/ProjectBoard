module Api
  module V1
    class StoriesController < Api::BaseController
      before_action :set_project
      before_action :set_story, only: [:show, :update, :destroy]
      before_action :convert_camel_to_snake_case, only: [:create, :update]

      def index
        @stories = @project.stories.includes(:assignee, :epic)
      end

      def show
      end

      def create
        @story = @project.stories.build(story_params)
        if @story.save
          render :create, status: :created
        else
          render json: { errors: @story.errors }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def update
        if @story.update(story_params)
          render :show
        else
          render json: { errors: @story.errors }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def destroy
        @story.destroy
        render json: { message: "Story deleted" }, status: :ok
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Project not found" }, status: :not_found
      end

      def set_story
        @story = @project.stories.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Story not found" }, status: :not_found
      end

      def convert_camel_to_snake_case
        if params[:story].present?
          params[:story] = params[:story].transform_keys { |key| key.to_s.underscore }
                                         .transform_values { |value| convert_enum_value(value) }
        end
      end

      def convert_enum_value(value)
        case value
        when String
          # Check if it's a numeric string (from Pivotal Tracker)
          if value.match?(/^\d+$/)
            value.to_i
          else
            value.underscore
          end
        when Integer
          # Handle numeric enum values - just return as-is
          # Priority: 0=lowest, 1=low, 2=medium, 3=high, 4=highest
          # Status: 0=icebox, 1=todo, 2=in_progress, 3=completed
          value
        else
          value
        end
      end

      def story_params
        params.require(:story).permit(:title, :description, :status, :priority, :assignee_id, :epic_id)
      end
    end
  end
end
