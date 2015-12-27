class AddTimestampsToLibraryStatusesTable < ActiveRecord::Migration
  def change
  	add_column :library_statuses, :created_at, :datetime, :default => Time.now
  	add_column :library_statuses, :updated_at, :datetime, :default => Time.now
  end
end
