class RenameProirtyToPriorityInStories < ActiveRecord::Migration[8.1]
  def change
    rename_column :stories, :priorty, :priority
  end
end
