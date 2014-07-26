class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mobile_phone

      t.timestamps
    end
    
    add_index :users, :mobile_phone, unique: true
  end
end
