json.key_format! camelize: :lower
json.array! @stories do |story|
  json.extract! story, :id, :title, :description, :status, :priority, :assignee_id, :epic_id, :project_id, :created_at, :updated_at
end
