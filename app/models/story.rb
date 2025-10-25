class Story < ApplicationRecord
  belongs_to :epic
  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id, optional: true

  enum :status, { icebox: 0, todo: 1, in_progress: 2, completed: 3 }
  enum :priority, { blocker: 0, high: 1, medium: 2, low: 3 }
end
