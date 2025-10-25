class AddPositionToStories < ActiveRecord::Migration[8.1]
  def change
    add_column :stories, :position, :integer, default: 0
    add_index :stories, [:status, :position]
  end
end
