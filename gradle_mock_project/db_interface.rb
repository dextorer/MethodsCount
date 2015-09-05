require 'active_record'
require 'mysql'

ActiveRecord::Base.establish_connection(
   :adapter  => "mysql",
   :host     => "localhost",
   :username => "lmc",
   :password => "***REMOVED***",
   :database => "methods_count"
)

class Libraries < ActiveRecord::Base
	self.table_name = "libraries"
end

class Dependencies < ActiveRecord::Base
	self.table_name = "dependencies"
end