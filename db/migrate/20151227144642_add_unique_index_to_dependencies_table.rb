class AddUniqueIndexToDependenciesTable < ActiveRecord::Migration
  def change
    execute <<-SQL
      alter table dependencies
        add constraint single_dependeny unique (library_name, dependency_name);
    SQL
  end
end
