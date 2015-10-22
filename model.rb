require 'active_record'

ActiveRecord::Base.establish_connection(
   :adapter  => "mysql2",
   :host     => ENV['RDS_HOSTNAME'] || "localhost",
   :username => ENV['RDS_USERNAME'] || "lmc",
   :password => ENV['RDS_PASSWORD'] || "***REMOVED***",
   :port => ENV['RDS_PORT'] || 3306,
   :database => ENV['RDS_DB_NAME'] || "methods_count"
)

class LibraryStatus < ActiveRecord::Base
end


class Libraries < ActiveRecord::Base
	self.table_name = "libraries"
end


class Dependencies < ActiveRecord::Base
	self.table_name = "dependencies"
end