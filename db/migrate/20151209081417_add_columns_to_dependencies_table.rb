class AddColumnsToDependenciesTable < ActiveRecord::Migration
  def change
    add_column :dependencies, :library_name, :string
    add_column :dependencies, :dependency_name, :string
    add_index :dependencies, :library_name
  end

  def data
    Dependencies.find_each do |dep|
      begin
        dep.library_name = Libraries.find(dep.library_id).fqn
        dep.dependency_name = Libraries.find(dep.dependency_id).fqn
        dep.save!
      rescue ActiveRecord::RecordNotFound
        LOGGER.error("Dependency #{dep.id} refers to non existing libraries")
      end
    end
  end
end
