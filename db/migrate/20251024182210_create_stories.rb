class CreateStories < ActiveRecord::Migration[8.1]
  def change
    create_table :stories do |t|
      t.string :title
      t.integer :status
      t.integer :priorty
      t.bigint :assignee_id
      t.belongs_to :epic, null: false, foreign_key: true
      t.belongs_to :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
