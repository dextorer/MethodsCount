class AddTimestampsToLibrariesTable < ActiveRecord::Migration
  def change
  	add_column :libraries, :created_at, :datetime
  	add_column :libraries, :updated_at, :datetime
  end

  def data
    ActiveRecord::Base.record_timestamps = false
  	Libraries.find_each do |lib|
  		lib.created_at ||= Time.at(lib.creation_time)
  		lib.updated_at ||= Time.at(lib.last_updated)
      lib.save!
  	end
    ActiveRecord::Base.record_timestamps = true
  end
end
