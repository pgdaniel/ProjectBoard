class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.belongs_to :organization, null: false, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
