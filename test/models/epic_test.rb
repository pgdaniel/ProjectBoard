require "test_helper"

class EpicTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @team = teams(:one)
    @project = Project.create!(
      name: "Test Project",
      team: @team,
      organization: @organization
    )
  end

  # Association Tests
  test "epic belongs to project" do
    epic = Epic.create!(
      project: @project,
      title: "Test Epic",
      type: "feature"
    )

    assert_equal @project, epic.project
  end

  test "epic has many stories" do
    epic = Epic.create!(
      project: @project,
      title: "Test Epic",
      type: "feature"
    )
    story1 = Story.create!(epic: epic, project: @project, title: "Story 1", status: "todo", priority: "high")
    story2 = Story.create!(epic: epic, project: @project, title: "Story 2", status: "todo", priority: "low")

    assert_includes epic.stories, story1
    assert_includes epic.stories, story2
    assert_equal 2, epic.stories.count
  end

  # Type Enum Tests
  test "epic has valid type enum values" do
    valid_types = [:feature, :backlog, :epic]

    valid_types.each do |type_value|
      epic = Epic.create!(
        project: @project,
        title: "Epic with #{type_value}",
        type: type_value
      )

      assert_equal type_value.to_s, epic.type, "Type should be #{type_value}"
    end
  end

  test "epic type enum has feature value" do
    epic = Epic.create!(project: @project, title: "Test", type: :feature)
    assert epic.feature?
  end

  test "epic type enum has backlog value" do
    epic = Epic.create!(project: @project, title: "Test", type: :backlog)
    assert epic.backlog?
  end

  test "epic type enum has epic value" do
    epic = Epic.create!(project: @project, title: "Test", type: :epic)
    assert epic.epic?
  end

  # Validation Tests
  test "epic requires project" do
    epic = Epic.new(
      title: "Test Epic",
      type: "feature"
    )

    assert_not epic.valid?
    assert epic.errors[:project].any?
  end

  test "epic requires title" do
    epic = Epic.new(
      project: @project,
      type: "feature"
    )

    assert_not epic.valid?
    assert epic.errors[:title].any?
  end

  test "epic requires type" do
    epic = Epic.new(
      project: @project,
      title: "Test Epic"
    )

    assert_not epic.valid?
    assert epic.errors[:type].any?
  end

  # Dependent Destroy Tests
  test "destroying epic destroys associated stories" do
    epic = Epic.create!(
      project: @project,
      title: "Test Epic",
      type: "feature"
    )
    story = Story.create!(epic: epic, project: @project, title: "Test Story", status: "todo", priority: "medium")
    story_id = story.id

    epic.destroy

    assert_nil Story.find_by(id: story_id)
  end

  # Creation Tests
  test "epic can be created with all valid attributes" do
    epic = Epic.create!(
      project: @project,
      title: "Complete Epic",
      description: "A detailed description",
      type: "feature"
    )

    assert epic.persisted?
    assert_equal "Complete Epic", epic.title
    assert_equal "A detailed description", epic.description
    assert_equal "feature", epic.type
  end

  test "multiple epics can exist for same project" do
    epic1 = Epic.create!(project: @project, title: "Epic 1", type: "feature")
    epic2 = Epic.create!(project: @project, title: "Epic 2", type: "backlog")
    epic3 = Epic.create!(project: @project, title: "Epic 3", type: "epic")

    project_epics = @project.epics

    assert_includes project_epics, epic1
    assert_includes project_epics, epic2
    assert_includes project_epics, epic3
    assert_equal 3, project_epics.count
  end
end
