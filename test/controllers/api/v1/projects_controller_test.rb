require "test_helper"

module Api
  module V1
    class ProjectsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @organization = organizations(:one)
        @team = teams(:one)
        @project = projects(:one)
        @project.update(team: @team, organization: @organization)
      end

      test "GET /api/v1/projects returns all projects" do
        get api_v1_projects_path

        assert_response :success
        response_data = JSON.parse(response.body)
        assert_kind_of Array, response_data
        assert response_data.length >= 1
      end

      test "GET /api/v1/projects includes organization_id and team_id" do
        get api_v1_projects_path

        assert_response :success
        response_data = JSON.parse(response.body)
        project_json = response_data.find { |p| p["id"] == @project.id }

        assert_not_nil project_json
        assert_equal @project.id, project_json["id"]
        assert_equal @organization.id, project_json["organizationId"]
        assert_equal @team.id, project_json["teamId"]
      end

      test "GET /api/v1/projects includes team association" do
        get api_v1_projects_path

        assert_response :success
        response_data = JSON.parse(response.body)
        project_json = response_data.find { |p| p["id"] == @project.id }

        assert_not_nil project_json["team"]
        assert_equal @team.id, project_json["team"]["id"]
      end

      test "GET /api/v1/projects/:id returns project details" do
        get api_v1_project_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_equal @project.id, response_data["id"]
        assert_equal @project.name, response_data["name"]
        assert_equal @project.description, response_data["description"]
      end

      test "GET /api/v1/projects/:id includes organization_id and team_id" do
        get api_v1_project_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_equal @organization.id, response_data["organizationId"]
        assert_equal @team.id, response_data["teamId"]
      end

      test "GET /api/v1/projects/:id returns 404 for non-existent project" do
        get api_v1_project_path(999999)

        assert_response :not_found
        response_data = JSON.parse(response.body)
        assert_equal "Project not found", response_data["error"]
      end

      test "POST /api/v1/projects creates a new project" do
        assert_difference("Project.count") do
          post api_v1_projects_path, params: {
            project: {
              name: "New Project",
              description: "A new project",
              team_id: @team.id,
              organization_id: @organization.id
            }
          }
        end

        assert_response :created
        response_data = JSON.parse(response.body)

        assert_equal "New Project", response_data["name"]
        assert_equal "A new project", response_data["description"]
        assert_equal @team.id, response_data["teamId"]
        assert_equal @organization.id, response_data["organizationId"]
      end

      test "POST /api/v1/projects with missing name returns error" do
        assert_no_difference("Project.count") do
          post api_v1_projects_path, params: {
            project: {
              description: "A project without name",
              team_id: @team.id,
              organization_id: @organization.id
            }
          }
        end

        assert_response :unprocessable_entity
        response_data = JSON.parse(response.body)
        assert response_data.has_key?("errors")
      end

      test "POST /api/v1/projects with missing team_id returns error" do
        assert_no_difference("Project.count") do
          post api_v1_projects_path, params: {
            project: {
              name: "Project without team",
              description: "Missing team",
              organization_id: @organization.id
            }
          }
        end

        assert_response :unprocessable_entity
      end

      test "PUT /api/v1/projects/:id updates a project" do
        put api_v1_project_path(@project), params: {
          project: {
            name: "Updated Project Name",
            description: "Updated description"
          }
        }

        assert_response :success
        @project.reload

        assert_equal "Updated Project Name", @project.name
        assert_equal "Updated description", @project.description
      end

      test "PUT /api/v1/projects/:id with invalid data returns error" do
        put api_v1_project_path(@project), params: {
          project: {
            name: ""
          }
        }

        assert_response :unprocessable_entity
        response_data = JSON.parse(response.body)
        assert response_data.has_key?("errors")
      end

      test "PUT /api/v1/projects/:id for non-existent project returns 404" do
        put api_v1_project_path(999999), params: {
          project: { name: "Updated" }
        }

        assert_response :not_found
        response_data = JSON.parse(response.body)
        assert_equal "Project not found", response_data["error"]
      end

      test "DELETE /api/v1/projects/:id deletes a project" do
        project_to_delete = projects(:two)

        assert_difference("Project.count", -1) do
          delete api_v1_project_path(project_to_delete)
        end

        assert_response :ok
        response_data = JSON.parse(response.body)
        assert_equal "Project deleted", response_data["message"]
      end

      test "DELETE /api/v1/projects/:id for non-existent project returns 404" do
        delete api_v1_project_path(999999)

        assert_response :not_found
        response_data = JSON.parse(response.body)
        assert_equal "Project not found", response_data["error"]
      end

      test "GET /api/v1/projects/:id includes epics" do
        epic = Epic.create!(project: @project, title: "Test Epic", type_enum: "feature")

        get api_v1_project_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_not_nil response_data["epics"]
        assert_kind_of Array, response_data["epics"]
      end

      test "GET /api/v1/projects/:id includes stories" do
        epic = Epic.create!(project: @project, title: "Test Epic", type_enum: "feature")
        story = Story.create!(epic: epic, project: @project, title: "Test Story", status: "todo", priority: "medium")

        get api_v1_project_path(@project)

        assert_response :success
        response_data = JSON.parse(response.body)

        assert_not_nil response_data["stories"]
        assert_kind_of Array, response_data["stories"]
      end
    end
  end
end
