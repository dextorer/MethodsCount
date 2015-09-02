require 'active_record'

ActiveRecord::Base.establish_connection(
   :adapter  => "mysql2",
   :host     => "localhost",
   :username => "lmc",
   :password => "***REMOVED***",
   :database => "methods_count"
)

class LibraryStatus < ActiveRecord::Base
end


