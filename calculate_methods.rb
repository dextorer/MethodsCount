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
	attr_accessor :skipped
end

class CalculateMethods
	
	@@tag = "[CalculateMethods]"

	@@logger = Logger.new(STDOUT)
	@@logger.level = Logger::DEBUG

	@@extracted_deps_dir = "extracted_deps"

	attr_reader :computed_library_list

	def initialize
		FileUtils.mkdir_p(@@extracted_deps_dir)
		@computed_library_list = Array.new
	end

	def run_build
		system("./gradlew -q compileDebugJava")
		build_result = $?
		if build_result == nil
			@@logger.error("Build failed")
			raise "Gradle build failed"
		end
	end

	def process_deps(library_fqn, deps_fqn_list)
		FileUtils.cd(@@extracted_deps_dir)

		Dir.foreach('.') do |item|
			@@logger.debug("#{@@tag} Processing library: #{item}")
			next if item == '.' or item == '..'
  			
			current_lib = Library.new

			# find library's FQN
			to_find = File.basename(item, File.extname(item))
			fqn_parts = tokenize_library_fqn(library_fqn)
			fqn_processed = "#{fqn_parts[1]}-#{fqn_parts[2]}"
			
			found = false
			if fqn_processed.include?(to_find)
				current_lib.library_fqn = library_fqn
				current_lib.is_main_library = true
				found = true
			else
				deps_fqn_list.each do |dep|
					dep_parts = tokenize_library_fqn(dep)
					dep_processed = "#{dep_parts[1]}-#{dep_parts[2]}"
					if to_find.include?(dep_processed)
						current_lib.library_fqn = dep
						current_lib.is_main_library = false
						found = true
					end
				end
			end

			if not found
				@@logger.debug("#{@@tag} [#{item}] Already computed, skipping")
				# this dependency has already been calculated
				current_lib.library_fqn = to_find
				current_lib.skipped = true
				@computed_library_list.push(current_lib)
				next
			end

			res_only = false
  			target = item
			if item.end_with?(".aar")
				@@logger.debug("#{@@tag} [#{item}] Format: AAR")
				# extract AAR's classes.jar
				system("unzip -q #{item} classes.jar")
				if File.exists?("classes.jar")
					new_filename = item.gsub(".aar", ".jar")
					FileUtils.mv("classes.jar", "#{new_filename}")
					target = new_filename
				else
					res_only = true
				end
			else
				@@logger.debug("#{@@tag} [#{item}] Format: JAR")
			end

			if not res_only
				@@logger.debug("#{@@tag} [#{item}] Target: #{target}")

				# calculate library size (in Bytes)
				size = File.size(target)
				current_lib.size = size

				@@logger.debug("#{@@tag} [#{item}] Size: #{size}")

				# build DEX file
				dx_path = ENV['DX_PATH']
				if dx_path.to_s.empty?
					dx_path = "dx"
				else
					dx_path = dx_path + "/dx"
				end

				if not File.exists?("#{target}")
					@@logger.error("#{@@tag} [#{item}] Target does not exist")
					raise "Target #{target} does not exist"
				end

				target_without_ext = File.basename(target, File.extname(target))
				system("#{dx_path} --dex --output=#{target_without_ext}.dex #{target}")
				dx_result = $?
				if dx_result == nil
					@@logger.error("Could not create DEX for #{target}")
					raise "Could not create DEX for #{target}"
				else
					@@logger.debug("#{@@tag} [#{item}] DXed successfully (result code: #{dx_result})")
				end
				
				# extract methods count, update counter
				count = `cat #{target_without_ext}.dex | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`
				current_lib.count = count.to_i()

				@@logger.debug("#{@@tag} [#{item}] Count: #{count}")
			else
				current_lib.size = 0
				current_lib.count = 0
				@@logger.debug("#{@@tag} [#{item}] Target: res-only")
				@@logger.debug("#{@@tag} [#{item}] Size: 0")
				@@logger.debug("#{@@tag} [#{item}] Count: 0")
			end

			# update library fields
			parts = tokenize_library_fqn(current_lib.library_fqn)
			current_lib.group_id = parts[0]
			current_lib.artifact_id = parts[1]
			current_lib.version = parts[2]

			@computed_library_list.push(current_lib)
		end

		FileUtils.cd("..")
	end

end

if __FILE__ == $0
	begin
		library_name = ARGV[0]
		if library_name.to_s.empty?
			library_name = "com.github.dextorer:sofa:1.0.0"
		end
		clone_workspace(library_name)

		compute_deps = ComputeDependencies.new(library_name)
		compute_deps.fetch_dependencies()

		calculate_methods = CalculateMethods.new
		calculate_methods.run_build()
		calculate_methods.process_deps(compute_deps.library_with_version, compute_deps.deps_fqn_list)

		puts calculate_methods.computed_library_list.inspect
	rescue => e
		puts "Failed, reason: #{e}"
	ensure
		restore_workspace
	end
end