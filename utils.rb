#/usr/bin/ruby

require 'fileutils'

class Utils

	def initialize
		@gradle_script = "build.gradle"
		@gradle_script_base = "build.gradle.base"
		@gradle_base_dir = "gradle_mock_project"
		@base_dir = ""
		@gradle_working_dir = ""
	end

	def init_gradle_files
		FileUtils.cp("#@gradle_working_dir/#@gradle_script_base", "#@gradle_working_dir/#@gradle_script")
	end

	def inject_library_name(library_name)
		text = File.read("#@gradle_working_dir/#@gradle_script")
		new_text = text.gsub(/dummy/, library_name)
		File.open("#@gradle_working_dir/#@gradle_script", "w") {|file| file.write(new_text) }
	end

	def tokenize_library_fqn(library_name)
		parts = library_name.split(/:/)
	end

	def clone_workspace(library_name)
		@base_dir = Dir.pwd
		now = Time.now.to_i
		@gradle_working_dir = library_name.gsub(/:/, '_') + now.to_s
		FileUtils.cp_r("#@gradle_base_dir", "#@gradle_working_dir")
	end

	def get_working_dir
		return @gradle_working_dir
	end

	def restore_workspace
		if @base_dir.nil? || @base_dir.empty?
			return
		end
		
		if File.exists?(@gradle_working_dir)
			FileUtils.rm_r(@gradle_working_dir)
		end
	end

end