class Project < ApplicationRecord
  belongs_to :team
  belongs_to :organization

  has_many :epics, dependent: :destroy
  has_many :stories, dependent: :destroy
end
