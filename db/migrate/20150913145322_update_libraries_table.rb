class UpdateLibrariesTable < ActiveRecord::Migration
  def change
  	add_column :libraries, :size, :integer, :default => 0
	change_column :libraries, :count, :integer, :limit => 6
  end
end
