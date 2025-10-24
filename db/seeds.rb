# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
[Story, Epic, Project, TeamMember, Team, Organization, User, Session].each(&:delete_all)

# Create Users
puts "Creating users..."
users = [
  User.create!(email_address: "alice@example.com", password: "password123", role: :admin),
  User.create!(email_address: "bob@example.com", password: "password123", role: :member),
  User.create!(email_address: "charlie@example.com", password: "password123", role: :member),
  User.create!(email_address: "diana@example.com", password: "password123", role: :member),
  User.create!(email_address: "eve@example.com", password: "password123", role: :member),
]

# Create Organization
puts "Creating organization..."
org = Organization.create!(
  name: "TechCorp",
  description: "A forward-thinking software company"
)

# Create Teams
puts "Creating teams..."
team_frontend = Team.create!(
  organization: org,
  name: "Frontend Team",
  description: "Building beautiful user interfaces"
)

team_backend = Team.create!(
  organization: org,
  name: "Backend Team",
  description: "Building robust APIs and services"
)

# Create Team Members
puts "Creating team members..."
TeamMember.create!(user: users[0], team: team_frontend, role: :admin)
TeamMember.create!(user: users[1], team: team_frontend, role: :member)
TeamMember.create!(user: users[2], team: team_frontend, role: :member)

TeamMember.create!(user: users[0], team: team_backend, role: :admin)
TeamMember.create!(user: users[3], team: team_backend, role: :member)
TeamMember.create!(user: users[4], team: team_backend, role: :member)

# Create Projects
puts "Creating projects..."
project_web = Project.create!(
  team: team_frontend,
  organization: org,
  name: "Website Redesign",
  description: "Modernizing the main website with React and TypeScript"
)

project_api = Project.create!(
  team: team_backend,
  organization: org,
  name: "API v2 Migration",
  description: "Migrating legacy REST API to GraphQL"
)

# Create Epics for Website Redesign project
puts "Creating epics..."
epic_ui = Epic.create!(
  project: project_web,
  title: "User Interface Overhaul",
  type: :feature
)

epic_perf = Epic.create!(
  project: project_web,
  title: "Performance Optimization",
  type: :feature
)

epic_testing = Epic.create!(
  project: project_web,
  title: "Testing Infrastructure",
  type: :backlog
)

# Create Epics for API project
epic_graphql = Epic.create!(
  project: project_api,
  title: "GraphQL Implementation",
  type: :feature
)

epic_auth = Epic.create!(
  project: project_api,
  title: "Authentication Refactor",
  type: :feature
)

# Story states: icebox: 0, todo: 1, in_progress: 2, completed: 3
# Story priorities: low: 0, medium: 1, high: 2

# Website Redesign Stories
puts "Creating stories for Website Redesign..."

story_titles_web = [
  "Design new landing page mockups",
  "Implement responsive navbar component",
  "Create reusable button component library",
  "Build product showcase carousel",
  "Add dark mode toggle",
  "Implement contact form validation",
  "Add image optimization pipeline",
  "Setup CSS-in-JS styling system",
  "Create accessibility audit checklist",
  "Migrate from Webpack to Vite",
  "Add type checking with TypeScript",
  "Implement lazy loading for images",
  "Create reusable modal components",
  "Setup automated visual regression testing",
  "Improve page load time",
]

Story.create!([
  # Icebox stories
  { epic: epic_ui, project: project_web, title: story_titles_web[0], status: :icebox, priority: :low, assignee: nil },
  { epic: epic_ui, project: project_web, title: story_titles_web[1], status: :icebox, priority: :medium, assignee: nil },
  { epic: epic_ui, project: project_web, title: story_titles_web[4], status: :icebox, priority: :low, assignee: nil },

  # Todo stories
  { epic: epic_ui, project: project_web, title: story_titles_web[2], status: :todo, priority: :high, assignee: users[1] },
  { epic: epic_ui, project: project_web, title: story_titles_web[3], status: :todo, priority: :high, assignee: nil },
  { epic: epic_perf, project: project_web, title: story_titles_web[10], status: :todo, priority: :medium, assignee: users[2] },
  { epic: epic_perf, project: project_web, title: story_titles_web[11], status: :todo, priority: :medium, assignee: nil },

  # In Progress stories
  { epic: epic_ui, project: project_web, title: story_titles_web[5], status: :in_progress, priority: :high, assignee: users[1] },
  { epic: epic_ui, project: project_web, title: story_titles_web[12], status: :in_progress, priority: :medium, assignee: users[2] },
  { epic: epic_perf, project: project_web, title: story_titles_web[9], status: :in_progress, priority: :high, assignee: users[1] },
  { epic: epic_testing, project: project_web, title: story_titles_web[13], status: :in_progress, priority: :medium, assignee: users[2] },

  # Completed stories
  { epic: epic_ui, project: project_web, title: story_titles_web[6], status: :completed, priority: :high, assignee: users[1] },
  { epic: epic_ui, project: project_web, title: story_titles_web[7], status: :completed, priority: :high, assignee: users[2] },
  { epic: epic_perf, project: project_web, title: story_titles_web[8], status: :completed, priority: :medium, assignee: users[1] },
  { epic: epic_perf, project: project_web, title: story_titles_web[14], status: :completed, priority: :high, assignee: users[2] },
])

# API v2 Migration Stories
puts "Creating stories for API v2 Migration..."

story_titles_api = [
  "Design GraphQL schema",
  "Setup Apollo Server",
  "Create User query resolver",
  "Create Post mutations",
  "Implement JWT authentication",
  "Add query complexity analysis",
  "Create subscription handlers",
  "Migrate REST endpoints to GraphQL",
  "Add request validation middleware",
  "Implement rate limiting",
  "Setup subscription WebSocket server",
  "Create error handling strategy",
  "Add GraphQL caching layer",
  "Migrate database queries",
  "Setup production monitoring",
]

Story.create!([
  # Icebox stories
  { epic: epic_graphql, project: project_api, title: story_titles_api[0], status: :icebox, priority: :high, assignee: nil },
  { epic: epic_auth, project: project_api, title: story_titles_api[4], status: :icebox, priority: :high, assignee: nil },
  { epic: epic_graphql, project: project_api, title: story_titles_api[6], status: :icebox, priority: :medium, assignee: nil },

  # Todo stories
  { epic: epic_graphql, project: project_api, title: story_titles_api[1], status: :todo, priority: :high, assignee: users[3] },
  { epic: epic_graphql, project: project_api, title: story_titles_api[2], status: :todo, priority: :high, assignee: nil },
  { epic: epic_graphql, project: project_api, title: story_titles_api[3], status: :todo, priority: :high, assignee: users[4] },
  { epic: epic_auth, project: project_api, title: story_titles_api[9], status: :todo, priority: :medium, assignee: nil },
  { epic: epic_graphql, project: project_api, title: story_titles_api[12], status: :todo, priority: :medium, assignee: users[3] },

  # In Progress stories
  { epic: epic_graphql, project: project_api, title: story_titles_api[5], status: :in_progress, priority: :high, assignee: users[3] },
  { epic: epic_graphql, project: project_api, title: story_titles_api[7], status: :in_progress, priority: :high, assignee: users[4] },
  { epic: epic_auth, project: project_api, title: story_titles_api[8], status: :in_progress, priority: :medium, assignee: users[3] },
  { epic: epic_graphql, project: project_api, title: story_titles_api[10], status: :in_progress, priority: :medium, assignee: users[4] },

  # Completed stories
  { epic: epic_graphql, project: project_api, title: story_titles_api[11], status: :completed, priority: :high, assignee: users[3] },
  { epic: epic_graphql, project: project_api, title: story_titles_api[13], status: :completed, priority: :high, assignee: users[4] },
  { epic: epic_auth, project: project_api, title: story_titles_api[14], status: :completed, priority: :medium, assignee: users[3] },
])

puts "✅ Seed data created successfully!"
puts "  - #{User.count} users"
puts "  - #{Organization.count} organization"
puts "  - #{Team.count} teams"
puts "  - #{TeamMember.count} team members"
puts "  - #{Project.count} projects"
puts "  - #{Epic.count} epics"
puts "  - #{Story.count} stories"
