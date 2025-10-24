class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :team_members
  has_many :teams, through: :team_members
  has_many :stories, foreign_key: :assignee_id

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { admin: 0, member: 1 }
end
