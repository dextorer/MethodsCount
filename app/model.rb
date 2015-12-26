require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: ENV['RDS_HOSTNAME'] || "localhost",
  username: ENV['RDS_USERNAME'] || "lmc",
  password: ENV['RDS_PASSWORD'] || "***REMOVED***",
  port: ENV['RDS_PORT'] || "3306",
  database: ENV['RDS_DB_NAME'] || "methods_count"
)

class LibraryStatus < ActiveRecord::Base
end


class Libraries < ActiveRecord::Base
  self.table_name = "libraries"

  def self.create_from_dep(dep)
    lib = Libraries.where(
      fqn: dep.fqn,
      group_id: dep.group_id,
      artifact_id: dep.artifact_id,
      version: dep.version
    ).first_or_create
    lib.count = dep.count
    lib.size = dep.size
    lib.dex_size = dep.dex_size
    lib.hit_count += 1
    lib.save!

    lib
  end
end


class Dependencies < ActiveRecord::Base
  self.table_name = "dependencies"
end
