class UpdateLibraryStatusTable < ActiveRecord::Migration
  def change
  	add_index :library_statuses, :library_name
  end
end
