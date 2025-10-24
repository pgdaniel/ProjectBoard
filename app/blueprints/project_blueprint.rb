class ProjectBlueprint < BaseBlueprint
  identifier :id
  field :name
  field :description
  field :team_id
  field :organization_id
  field :created_at
  field :updated_at

  association :team, blueprint: TeamBlueprint
  association :epics, blueprint: EpicBlueprint
  association :stories, blueprint: StoryBlueprint
end
