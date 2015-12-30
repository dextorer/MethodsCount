class AddIdToDependenciesTable < ActiveRecord::Migration
  def change
  	add_column :dependencies, :id, :primary_key
  end
end
