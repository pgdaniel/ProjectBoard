json.key_format! camelize: :lower
json.array! @projects do |project|
  json.partial! "api/v1/projects/api_v1_project", api_v1_project: project
end
