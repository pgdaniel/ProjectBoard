require "test_helper"

class StoryTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @team = teams(:one)
    @project = projects(:one)
    @project.update(team: @team, organization: @organization)
    @epic = Epic.create!(project: @project, title: "Test Epic", type_enum: "feature")
  end

  # Association Tests
  test "story belongs to epic" do
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )

    assert_equal @epic, story.epic
  end

  test "story belongs to project" do
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )

    assert_equal @project, story.project
  end

  test "story can have optional assignee" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123"
    )
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium",
      assignee: user
    )

    assert_equal user, story.assignee
  end

  test "story can be created without assignee" do
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )

    assert_nil story.assignee
  end

  # Status Enum Tests
  test "story has valid status enum values" do
    valid_statuses = [:icebox, :todo, :in_progress, :completed]

    valid_statuses.each do |status|
      story = Story.create!(
        epic: @epic,
        project: @project,
        title: "Story with #{status}",
        status: status,
        priority: "medium"
      )

      assert_equal status.to_s, story.status, "Status should be #{status}"
    end
  end

  test "story status enum has icebox value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: :icebox, priority: "medium")
    assert story.icebox?
  end

  test "story status enum has todo value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: :todo, priority: "medium")
    assert story.todo?
  end

  test "story status enum has in_progress value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: :in_progress, priority: "medium")
    assert story.in_progress?
  end

  test "story status enum has completed value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: :completed, priority: "medium")
    assert story.completed?
  end

  # Priority Enum Tests
  test "story has valid priority enum values" do
    valid_priorities = [:low, :medium, :high]

    valid_priorities.each do |priority|
      story = Story.create!(
        epic: @epic,
        project: @project,
        title: "Story with #{priority}",
        status: "todo",
        priority: priority
      )

      assert_equal priority.to_s, story.priority, "Priority should be #{priority}"
    end
  end

  test "story priority enum has low value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: "todo", priority: :low)
    assert story.low?
  end

  test "story priority enum has medium value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: "todo", priority: :medium)
    assert story.medium?
  end

  test "story priority enum has high value" do
    story = Story.create!(epic: @epic, project: @project, title: "Test", status: "todo", priority: :high)
    assert story.high?
  end

  # Validation Tests
  test "story requires epic" do
    story = Story.new(
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )

    assert_not story.valid?
    assert story.errors[:epic].any?
  end

  test "story requires project" do
    story = Story.new(
      epic: @epic,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )

    assert_not story.valid?
    assert story.errors[:project].any?
  end

  test "story requires title" do
    story = Story.new(
      epic: @epic,
      project: @project,
      status: "todo",
      priority: "medium"
    )

    assert_not story.valid?
    assert story.errors[:title].any?
  end

  test "story requires status" do
    story = Story.new(
      epic: @epic,
      project: @project,
      title: "Test Story",
      priority: "medium"
    )

    assert_not story.valid?
    assert story.errors[:status].any?
  end

  test "story requires priority" do
    story = Story.new(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo"
    )

    assert_not story.valid?
    assert story.errors[:priority].any?
  end

  # Dependent Destroy Tests
  test "deleting epic destroys associated stories" do
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Test Story",
      status: "todo",
      priority: "medium"
    )
    story_id = story.id

    @epic.destroy

    assert_nil Story.find_by(id: story_id)
  end

  # Creation Tests
  test "story can be created with all valid attributes" do
    story = Story.create!(
      epic: @epic,
      project: @project,
      title: "Complete Story",
      status: "in_progress",
      priority: "high",
      description: "A detailed description"
    )

    assert story.persisted?
    assert_equal "Complete Story", story.title
    assert_equal "in_progress", story.status
    assert_equal "high", story.priority
  end
end
