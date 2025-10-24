class Team < ApplicationRecord
  belongs_to :organization

  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :projects
end
