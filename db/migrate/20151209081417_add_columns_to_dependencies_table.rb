class AddColumnsToDependenciesTable < ActiveRecord::Migration
  def change
  	add_column :dependencies, :library_name, :string
  	add_column :dependencies, :dependency_name, :string
  	add_index :dependencies, :library_name
  end

  def data
  	Dependencies.all.each do |dep|
  		dep.update_attribute(:library_name, Libraries.find(dep.library_id).fqn)
  		dep.update_attribute(:dependency_name, Libraries.find(dep.dependency_id).fqn)
  	end
  end
end
