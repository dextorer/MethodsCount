class UpdateLibraryTable < ActiveRecord::Migration
  def change
  	add_column :libraries, :dex_size, :integer, :default => 0
  	add_index :libraries, :fqn
  end
end
