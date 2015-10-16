class AddCountAndTimestampToLibrariesTable < ActiveRecord::Migration
  def change
  	add_column :libraries, :hit_count, :integer, :default => 0
  	add_column :libraries, :creation_time, :integer, :default => 0
  	add_column :libraries, :last_updated, :integer, :default => 0
  end
end
