#/usr/bin/ruby

require 'fileutils'
require 'logger'
require_relative 'utils'
require_relative 'compute_deps_name'

class Library
	attr_accessor :library_fqn
	attr_accessor :group_id
	attr_accessor :artifact_id
	attr_accessor :version
	attr_accessor :count
	attr_accessor :size
	attr_accessor :is_main_library
end

class CalculateMethods
	
	logger = Logger.new(STDOUT)
	logger.level = Logger::DEBUG

	@@extracted_deps_dir = "extracted_deps"

	attr_reader :computed_library_list

	def initialize
		FileUtils.mkdir_p(@@extracted_deps_dir)
		@computed_library_list = Array.new
	end

	def run_build
		system("./gradlew -q compileDebugJava")
		_build_result = $?
		if _build_result == nil
			logger.error("3. Build failed")
			abort("ABORTING")
		end
	end

	def process_deps(library_fqn, deps_fqn_list)
		FileUtils.cd(@@extracted_deps_dir)

		Dir.foreach('.') do |item|
			next if item == '.' or item == '..'
  			
			_current_lib = Library.new

  			_target = item
			if item.end_with?(".aar")
				# extract AAR's classes.jar
				system("unzip -q #{item} classes.jar")
				_new_filename = item.gsub(".aar", ".jar")
				FileUtils.mv("classes.jar", "#{_new_filename}")
				_target = _new_filename
			end

			# calculate library size (in Bytes)
			_size = File.size(_target)
			_current_lib.size = _size

			# build DEX file
			system("dx --dex --output=temp.dex #{_target}")
			_dx_result = $?
			if _dx_result == nil
				logger.error("Could not create DEX for #{target}")
				abort("ABORTING")
			end
			
			# extract methods count, update counter
			_count = `cat temp.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`
			_current_lib.count = _count.to_i

			# find library's FQN
			_to_find = File.basename(item, File.extname(item))
			_to_find.gsub!(/(.*)-(.*)/, '\1:\2')

			if library_fqn.include?(_to_find)
				_current_lib.library_fqn = library_fqn
				_current_lib.is_main_library = true
			else
				deps_fqn_list.each do |dep|
					if dep.include?(_to_find)
						_current_lib.library_fqn = dep
						_current_lib.is_main_library = false
					end
				end
			end

			# update library fields
			_parts = tokenize_library_fqn(_current_lib.library_fqn)
			_current_lib.group_id = _parts[0]
			_current_lib.artifact_id = _parts[1]
			_current_lib.version = _parts[2]

			@computed_library_list.push(_current_lib)
		end

		FileUtils.cd("..")
	end

end

if __FILE__ == $0
	init_gradle_files
	inject_library_name "com.github.dextorer:sofa:1.0.0"

	compute_deps = ComputeDependencies.new
	compute_deps.fetch_dependencies

	calculate_methods = CalculateMethods.new
	calculate_methods.run_build
	calculate_methods.process_deps(compute_deps.library_fqn, compute_deps.deps_fqn_list)

	puts calculate_methods.computed_library_list.inspect
	
	Signal.trap("EXIT") do
		restore_workspace		
	end
end