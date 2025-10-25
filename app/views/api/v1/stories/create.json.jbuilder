json.key_format! camelize: :lower
json.extract! @story, :id, :title, :priority, :assignee_id, :epic_id, :project_id, :position, :created_at, :updated_at
json.status @story.status.camelize(:lower)
