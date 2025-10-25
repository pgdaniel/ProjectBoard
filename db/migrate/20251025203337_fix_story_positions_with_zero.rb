class FixStoryPositionsWithZero < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        # For each status, renumber stories with position 0 to proper positions
        Story.statuses.each do |status_name, status_value|
          stories_with_zero = Story.where(status: status_value, position: 0).order(:created_at)
          max_position = Story.where(status: status_value).where.not(position: 0).maximum(:position) || 0

          stories_with_zero.each_with_index do |story, index|
            story.update(position: max_position + index + 1)
          end
        end
      end
    end
  end
end
