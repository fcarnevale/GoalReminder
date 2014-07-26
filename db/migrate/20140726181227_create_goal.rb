class CreateGoal < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
  end
end
