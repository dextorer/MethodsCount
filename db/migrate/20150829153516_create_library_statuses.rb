class CreateLibraryStatuses < ActiveRecord::Migration
	def up
		create_table :library_statuses do |t|
			t.string :library_name
			t.string :status
		end
	end
end
