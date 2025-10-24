class StoryBlueprint < BaseBlueprint
  identifier :id
  field :title
  field :status
  field :priority
  field :epic_id
  field :project_id
  field :created_at
  field :updated_at

  association :assignee, blueprint: UserBlueprint
end
