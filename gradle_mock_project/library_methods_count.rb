#/usr/bin/ruby

require 'rubygems'  
require 'fileutils'
require 'logger'
require 'json'

require_relative 'utils'
require_relative 'compute_deps_name'
require_relative 'calculate_methods'
require_relative 'db_interface'

class LibraryMethodsCount

	attr_writer :library_fqn

	logger = Logger.new(STDOUT)
	logger.level = Logger::DEBUG

	def retrieve_from_db
		Libraries.find_by_fqn(@library_fqn)
	end

	def process_library
		init_gradle_files()
		inject_library_name("#@library_fqn")

		# compute FQNs for both library and dependencies
		compute_deps = ComputeDependencies.new
		compute_deps.fetch_dependencies()

		# compute methods count for both library and dependencies
		calculate_methods = CalculateMethods.new
		calculate_methods.run_build()
		calculate_methods.process_deps(compute_deps.library_fqn, compute_deps.deps_fqn_list)

		# write result to DB (insert into Libraries first)
		inserted_id = -1 
		calculate_methods.computed_library_list.each do |lib|
			Libraries.create(fqn: lib.library_fqn, group_id: lib.group_id, artifact_id: lib.artifact_id, version: lib.version, count: lib.count, size: lib.size)
			if lib.is_main_library
				inserted_id = Libraries.find_by_fqn(lib.library_fqn).id
			end
		end

		if inserted_id < 0
			logger.error("DB insertion failed")
			abort("ABORTING")
		end

		calculate_methods.computed_library_list.each do |lib|
			next if lib.is_main_library == true
			
			dep_id = Libraries.find_by_fqn(lib.library_fqn).id
			Dependencies.create(library_id: inserted_id, dependency_id: dep_id)
		end
	end

	def generate_response
		lib = Libraries.where(:fqn => @library_fqn).first
		deps = Dependencies.where(library_id: lib.id).all
		deps_array = Array.new
		deps.each do |dep|
			dep_id = dep.dependency_id
			dep_lib = Libraries.find(dep_id.to_i)
			deps_array.push({ :dependency_name => dep_lib.fqn, :dependency_count => dep_lib.count })
		end
		
		response = {:library_fqn => lib.fqn, :library_methods => lib.count, :dependencies_count => deps.length, :dependencies => deps_array}
		puts response.to_json
	end

end

if __FILE__ == $0
	system("export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH")
	restore_workspace()

	lib_fqn = ARGV[0]
	if lib_fqn.nil? || lib_fqn.empty?
		Logger.new(STDOUT).error("No library FQN supplied")
		abort("ABORTING")
	end

	library_methods_count = LibraryMethodsCount.new
	library_methods_count.library_fqn = lib_fqn
	lib = library_methods_count.retrieve_from_db()
	if lib == nil
		library_methods_count.process_library()
	end
	library_methods_count.generate_response()

	Signal.trap("EXIT") do
		restore_workspace()
	end
end