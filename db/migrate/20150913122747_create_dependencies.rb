class CreateDependencies < ActiveRecord::Migration
  def up
    create_table :dependencies, id: false do |t|
      t.integer :library_id,    limit: 4, null: false
      t.integer :dependency_id, limit: 4, null: false
    end
  end
end
