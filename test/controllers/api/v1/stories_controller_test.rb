require "test_helper"

module Api
  module V1
    class StoriesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @organization = organizations(:one)
        @team = teams(:one)
        @project = projects(:one)
        @project.update(team: @team, organization: @organization)
        @epic = Epic.create!(project: @project, title: "Test Epic", type_enum: "feature")
        @story = Story.create!(
          epic: @epic,
          project: @project,
          title: "Test Story",
          status: "todo",
          priority: "medium"
        )
      end

      test "GET /api/v1/projects/:project_id/stories returns all stories for project" do
        get api_v1_project_stories_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)
        assert_kind_of Array, response_data
        assert response_data.length >= 1
      end

      test "GET /api/v1/projects/:project_id/stories includes required fields" do
        get api_v1_project_stories_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)
        story_json = response_data.find { |s| s["id"] == @story.id }

        assert_not_nil story_json
        assert_equal @story.id, story_json["id"]
        assert_equal @story.title, story_json["title"]
        assert_equal @story.status, story_json["status"]
        assert_equal @story.priority, story_json["priority"]
      end

      test "GET /api/v1/projects/:project_id/stories/:id returns story details" do
        get api_v1_project_story_path(@project, @story)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_equal @story.id, response_data["id"]
        assert_equal @story.title, response_data["title"]
        assert_equal @story.epic_id, response_data["epicId"]
      end

      test "GET /api/v1/projects/:project_id/stories/:id returns 404 for non-existent story" do
        get api_v1_project_story_path(@project, 999999)

        assert_response :not_found
      end

      test "POST /api/v1/projects/:project_id/stories creates a new story" do
        assert_difference("Story.count") do
          post api_v1_project_stories_path(@project), params: {
            story: {
              title: "New Story",
              epicId: @epic.id,
              status: "todo",
              priority: "high"
            }
          }
        end

        assert_response :created
        response_data = JSON.parse(response.body)

        assert_equal "New Story", response_data["title"]
        assert_equal "todo", response_data["status"]
        assert_equal "high", response_data["priority"]
      end

      test "POST /api/v1/projects/:project_id/stories converts camelCase parameters to snake_case" do
        post api_v1_project_stories_path(@project), params: {
          story: {
            title: "Test Story",
            epicId: @epic.id,
            status: "inProgress",
            priority: "high"
          }
        }

        assert_response :created
        created_story = Story.last

        assert_equal "Test Story", created_story.title
        assert_equal "in_progress", created_story.status
        assert_equal "high", created_story.priority
      end

      test "POST /api/v1/projects/:project_id/stories with missing title returns error" do
        assert_no_difference("Story.count") do
          post api_v1_project_stories_path(@project), params: {
            story: {
              epicId: @epic.id,
              status: "todo",
              priority: "medium"
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "PUT /api/v1/projects/:project_id/stories/:id updates a story" do
        put api_v1_project_story_path(@project, @story), params: {
          story: {
            title: "Updated Story Title",
            status: "inProgress",
            priority: "high"
          }
        }

        assert_response :success
        @story.reload

        assert_equal "Updated Story Title", @story.title
        assert_equal "in_progress", @story.status
        assert_equal "high", @story.priority
      end

      test "PUT /api/v1/projects/:project_id/stories/:id converts camelCase to snake_case" do
        put api_v1_project_story_path(@project, @story), params: {
          story: {
            status: "completed",
            priority: "low"
          }
        }

        assert_response :success
        @story.reload

        assert_equal "completed", @story.status
        assert_equal "low", @story.priority
      end

      test "PUT /api/v1/projects/:project_id/stories/:id for non-existent story returns 404" do
        put api_v1_project_story_path(@project, 999999), params: {
          story: { title: "Updated" }
        }

        assert_response :not_found
      end

      test "DELETE /api/v1/projects/:project_id/stories/:id deletes a story" do
        story_to_delete = Story.create!(
          epic: @epic,
          project: @project,
          title: "Story to Delete",
          status: "todo",
          priority: "low"
        )

        assert_difference("Story.count", -1) do
          delete api_v1_project_story_path(@project, story_to_delete)
        end

        assert_response :ok
      end

      test "DELETE /api/v1/projects/:project_id/stories/:id for non-existent story returns 404" do
        delete api_v1_project_story_path(@project, 999999)

        assert_response :not_found
      end

      test "POST /api/v1/projects/:project_id/stories with valid status enum" do
        ["todo", "icebox", "inProgress", "completed"].each do |status|
          post api_v1_project_stories_path(@project), params: {
            story: {
              title: "Story with #{status}",
              epicId: @epic.id,
              status: status,
              priority: "medium"
            }
          }

          assert_response :created, "Failed to create story with status: #{status}"
        end
      end

      test "POST /api/v1/projects/:project_id/stories with valid priority enum" do
        ["low", "medium", "high"].each do |priority|
          post api_v1_project_stories_path(@project), params: {
            story: {
              title: "Story with #{priority} priority",
              epicId: @epic.id,
              status: "todo",
              priority: priority
            }
          }

          assert_response :created, "Failed to create story with priority: #{priority}"
        end
      end

      test "GET /api/v1/projects/:project_id/stories includes assignee when present" do
        user = User.create!(
          email_address: "assignee@example.com",
          password: "password123"
        )
        @story.update(assignee: user)

        get api_v1_project_story_path(@project, @story)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_not_nil response_data["assignee"]
        assert_equal user.id, response_data["assignee"]["id"]
      end

      test "GET /api/v1/projects/:project_id/stories returns correct camelCase field names" do
        get api_v1_project_story_path(@project, @story)

        assert_response :success
        response_data = JSON.parse(response.body)

        # Check that fields are in camelCase, not snake_case
        assert response_data.has_key?("epicId"), "Should have epicId (camelCase)"
        assert response_data.has_key?("projectId"), "Should have projectId (camelCase)"
        assert !response_data.has_key?("epic_id"), "Should not have epic_id (snake_case)"
        assert !response_data.has_key?("project_id"), "Should not have project_id (snake_case)"
      end
    end
  end
end
