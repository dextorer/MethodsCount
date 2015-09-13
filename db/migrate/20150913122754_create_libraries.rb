class CreateLibraries < ActiveRecord::Migration
  def up
    create_table :libraries do |t|
      t.string  :fqn,         limit: 255,             null: false
      t.integer :count,       limit: 4,   default: 0
      t.string  :group_id,    limit: 255,             null: false
      t.string  :artifact_id, limit: 255,             null: false
      t.string  :version,     limit: 255,             null: false
    end
  end
end
