class TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :team

  # - unique combination of team_id and user_id
  enum :role, { admin: 0, member: 1 }
end
