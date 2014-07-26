class AddActiveToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :active, :boolean, :default => false
  end
end
