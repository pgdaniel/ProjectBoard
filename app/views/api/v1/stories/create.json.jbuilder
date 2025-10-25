json.key_format! camelize: :lower
json.extract! @story, :id, :title, :status, :priority, :assignee_id, :epic_id, :project_id, :created_at, :updated_at
