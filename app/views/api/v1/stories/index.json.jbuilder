json.key_format! camelize: :lower
json.array! @stories do |story|
  json.extract! story, :id, :title, :description, :priority, :assignee_id, :epic_id, :project_id, :position, :created_at, :updated_at
  json.status story.status.camelize(:lower)
end
