class CreateEpics < ActiveRecord::Migration[8.1]
  def change
    create_table :epics do |t|
      t.string :title
      t.integer :type
      t.belongs_to :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
