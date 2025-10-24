class Organization < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :projects, dependent: :destroy
end
