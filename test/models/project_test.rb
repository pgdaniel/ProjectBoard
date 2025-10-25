require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @team = teams(:one)
  end

  # Association Tests
  test "project belongs to team" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )

    assert_equal @team, project.team
  end

  test "project belongs to organization" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )

    assert_equal @organization, project.organization
  end

  test "project has many epics" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )
    epic1 = Epic.create!(project: project, title: "Epic 1", type_enum: "feature")
    epic2 = Epic.create!(project: project, title: "Epic 2", type_enum: "backlog")

    assert_includes project.epics, epic1
    assert_includes project.epics, epic2
    assert_equal 2, project.epics.count
  end

  test "project has many stories" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )
    epic = Epic.create!(project: project, title: "Test Epic", type_enum: "feature")
    story1 = Story.create!(epic: epic, project: project, title: "Story 1", status: "todo", priority: "high")
    story2 = Story.create!(epic: epic, project: project, title: "Story 2", status: "todo", priority: "low")

    assert_includes project.stories, story1
    assert_includes project.stories, story2
    assert_equal 2, project.stories.count
  end

  # Validation Tests
  test "project requires name" do
    project = Project.new(
      team: @team,
      organization: @organization
    )

    assert_not project.valid?
    assert project.errors[:name].any?
  end

  test "project requires team" do
    project = Project.new(
      name: "Test Project",
      organization: @organization
    )

    assert_not project.valid?
    assert project.errors[:team].any?
  end

  test "project requires organization" do
    project = Project.new(
      name: "Test Project",
      team: @team
    )

    assert_not project.valid?
    assert project.errors[:organization].any?
  end

  # Dependent Destroy Tests
  test "destroying project destroys associated epics" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )
    epic = Epic.create!(project: project, title: "Test Epic", type_enum: "feature")
    epic_id = epic.id

    project.destroy

    assert_nil Epic.find_by(id: epic_id)
  end

  test "destroying project destroys associated stories" do
    project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )
    epic = Epic.create!(project: project, title: "Test Epic", type_enum: "feature")
    story = Story.create!(epic: epic, project: project, title: "Test Story", status: "todo", priority: "medium")
    story_id = story.id

    project.destroy

    assert_nil Story.find_by(id: story_id)
  end

  # Creation Tests
  test "project can be created with all valid attributes" do
    project = Project.create!(
      name: "New Project",
      description: "A detailed description",
      team: @team,
      organization: @organization
    )

    assert project.persisted?
    assert_equal "New Project", project.name
    assert_equal "A detailed description", project.description
  end

  test "multiple projects can exist for same team" do
    project1 = Project.create!(name: "Project 1", team: @team, organization: @organization)
    project2 = Project.create!(name: "Project 2", team: @team, organization: @organization)

    team_projects = @team.projects

    assert_includes team_projects, project1
    assert_includes team_projects, project2
    assert_equal 2, team_projects.count
  end

  test "multiple projects can exist for same organization" do
    project1 = Project.create!(name: "Project 1", team: @team, organization: @organization)
    project2 = Project.create!(name: "Project 2", team: @team, organization: @organization)

    org_projects = @organization.projects

    assert_includes org_projects, project1
    assert_includes org_projects, project2
    assert_equal 2, org_projects.count
  end
end
