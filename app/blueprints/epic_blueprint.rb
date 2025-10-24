class EpicBlueprint < BaseBlueprint
  identifier :id
  field :title
  field :type
  field :project_id
  field :created_at
  field :updated_at

  association :stories, blueprint: StoryBlueprint
end
