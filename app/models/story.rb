class Story < ApplicationRecord
  belongs_to :epic
  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id, optional: true

  enum :status, { icebox: 0, todo: 1, in_progress: 2, completed: 3 }

  # Automatically set position to the next available position in the status column
  before_create :set_default_position

  # Scope to order by position
  scope :ordered, -> { order(:position) }

  private

  def set_default_position
    if position.nil? || position == 0
      max_position = Story.where(status: status).maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
