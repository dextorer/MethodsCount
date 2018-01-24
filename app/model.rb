require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: ENV['RDS_HOSTNAME'] || "localhost",
  username: ENV['RDS_USERNAME'] || "lmc",
  password: ENV['RDS_PASSWORD'] || "trolololol",
  port: ENV['RDS_PORT'] || "3306",
  database: ENV['RDS_DB_NAME'] || "methods_count"
)

class LibraryStatus < ActiveRecord::Base
end


class Libraries < ActiveRecord::Base
  self.table_name = "libraries"

  scope :top, ->(count) { Libraries.order(hit_count: :desc).distinct(true).take(count) }

  def self.create_from_dep(dep)
    lib = Libraries.where(
      fqn: dep.fqn,
      group_id: dep.group_id,
      artifact_id: dep.artifact_id,
      version: dep.version
    ).first_or_create
    lib.count = dep.count unless dep.count.nil?
    lib.size = dep.size unless dep.size.nil?
    lib.dex_size = dep.dex_size unless dep.dex_size.nil?
    lib.hit_count += 1
    lib.save!

    lib
  end
end


class Dependencies < ActiveRecord::Base
  self.table_name = "dependencies"
end
