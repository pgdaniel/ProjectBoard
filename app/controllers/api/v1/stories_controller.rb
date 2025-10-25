module Api
  module V1
    class StoriesController < Api::BaseController
      before_action :set_project
      before_action :set_story, only: [:show, :update, :destroy]
      before_action :convert_camel_to_snake_case, only: [:create, :update]

      def index
        @stories = @project.stories.includes(:assignee, :epic).ordered
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
        old_status = @story.status
        old_position = @story.position

        if @story.update(story_params)
          # Handle status change
          if old_status != @story.status
            reorder_stories_if_status_changed(old_status, @story.status)
          # Handle position change within same status
          elsif old_position != @story.position && story_params.key?(:position)
            reorder_within_status(@story.status, old_position, @story.position, @story.id)
          end
          render :show
        else
          render json: { errors: @story.errors }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def destroy
        old_status = @story.status
        @story.destroy
        # Compact positions after deletion
        compact_positions(old_status)
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
        params.require(:story).permit(:title, :description, :status, :priority, :assignee_id, :epic_id, :position)
      end

      def reorder_stories_if_status_changed(old_status, new_status)
        return if old_status == new_status

        # Compact positions in old status
        compact_positions(old_status)
        # Assign new position in new status
        reposition_story(@story, new_status)
      end

      def compact_positions(status)
        # Reorder remaining stories to have consecutive positions starting from 1
        @project.stories.where(status: status).ordered.each_with_index do |story, index|
          story.update_column(:position, index + 1)
        end
      end

      def reposition_story(story, status)
        # Use the position provided in the request, or put at end if not provided
        if story.position.nil? || story.position == 0
          # Assign position to the end of the column (0 means not set)
          max_position = @project.stories.where(status: status).where.not(id: story.id).maximum(:position) || 0
          story.update_column(:position, max_position + 1)
        else
          # Shift other stories down if needed
          shift_positions_down(status, story.position, story.id)
        end
      end

      def shift_positions_down(status, insert_position, story_id)
        # Shift other stories at or after this position down by 1
        @project.stories.where(status: status)
                        .where.not(id: story_id)
                        .where('position >= ?', insert_position)
                        .update_all('position = position + 1')
      end

      def reorder_within_status(status, old_position, new_position, story_id)
        # Handle reordering within the same status column
        if new_position < old_position
          # Moving up: shift stories between new and old position down
          @project.stories.where(status: status)
                          .where.not(id: story_id)
                          .where('position >= ? AND position < ?', new_position, old_position)
                          .update_all('position = position + 1')
        elsif new_position > old_position
          # Moving down: shift stories between old and new position up
          @project.stories.where(status: status)
                          .where.not(id: story_id)
                          .where('position > ? AND position <= ?', old_position, new_position)
                          .update_all('position = position - 1')
        end
      end
    end
  end
end
