json.key_format! camelize: :lower

project = local_assigns[:api_v1_project] || @project

json.extract! project, :id, :name, :description, :team_id, :organization_id, :created_at, :updated_at

json.team do
  if project.team
    json.extract! project.team, :id, :name, :description
  else
    json.null!
  end
end

json.epics project.epics do |epic|
  json.extract! epic, :id, :title, :type, :created_at, :updated_at
  json.stories epic.stories do |story|
    json.extract! story, :id, :title, :priority, :assignee_id, :epic_id, :project_id, :position, :created_at, :updated_at
    json.status story.status.camelize(:lower)
  end
end

json.stories project.stories do |story|
  # ensure description is always a string to match API consumers
  json.extract! story, :id, :title, :priority, :assignee_id, :epic_id, :project_id, :position, :created_at, :updated_at
  json.status story.status.camelize(:lower)
end
