class AddTimestampsToLibrariesTable < ActiveRecord::Migration
  def change
  	add_column :libraries, :created_at, :datetime
  	add_column :libraries, :updated_at, :datetime
  end

  def data
  	Libraries.find_each do |lib|
  		lib.update_attribute(:created_at, Time.at(lib.creation_time))
  		lib.update_attribute(:updated_at, Time.at(lib.last_updated)) 
  	end
  end
end
