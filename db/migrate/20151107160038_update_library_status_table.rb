class UpdateLibraryStatusTable < ActiveRecord::Migration
  def change
  	add_index :library_status, :library_name
  end
end
