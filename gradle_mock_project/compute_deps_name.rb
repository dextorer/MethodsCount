#/usr/bin/ruby

require 'fileutils'
require_relative 'utils'

class ComputeDependencies 

	attr_reader :library_fqn
	attr_reader :deps_fqn_list

	def initialiaze(library_name)
		@library = library_name
	end

	def fetch_dependencies
		init_gradle_files()
		inject_library_name(@library)

		deps_raw = `./gradlew dependencies`

		# extract only the dependencies part
		substr_begin = deps_raw.index(/default\s+-\s+/)
		substr_end = deps_raw.index(/default-mapping\s+-\s+/, substr_begin)
		substr = deps_raw.slice(substr_begin .. substr_end - 1)
		
		@deps_fqn_list = []
		substr.delete! ' |'
		substr.each_line do |line|
			if line[/^(\\|\+|\|){1}-+.*?/]
				updated_line = line.gsub(/^(\\|\+|\|){1}-+/, '').gsub(/\(\*\)/, '').gsub(/\n/, '')
				if line.include?("+")
					updated_line.gsub!(/(.*):[^>]*>(.*)/, '\1:\2')
				end
				@deps_fqn_list.push(updated_line)
			end
		end

		# the first entry is the requested library
		@library_with_version = deps_fqn_list[0]
		@deps_fqn_list.delete_at(0)
	end
end

if __FILE__ == $0
	init_gradle_files()
	inject_library_name("com.github.dextorer:sofa:1.+")
	
	c = ComputeDependencies.new
	c.fetch_dependencies()
	
	puts c.library_fqn
	puts c.deps_fqn_list
	
	restore_workspace()
end