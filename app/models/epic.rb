class Epic < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :project

  has_many :stories, dependent: :destroy

  enum :type, { feature: 0, backlog: 1, epic: 2 }
end
