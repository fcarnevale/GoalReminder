class CreateMood < ActiveRecord::Migration
  def change
    create_table :moods do |t|
      t.integer :level
      t.string :content
      t.integer :user_id

      t.timestamps
    end
  end
end
