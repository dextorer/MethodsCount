#/usr/bin/ruby

require 'fileutils'
require_relative 'utils'

class ComputeDependencies 

	attr_reader :library_fqn
	attr_reader :deps_fqn_list

	def fetch_dependencies
		_deps_raw = `./gradlew dependencies`

		# extract only the dependencies part
		_substr_begin = _deps_raw.index(/default\s+-\s+/)
		_substr_end = _deps_raw.index(/default-mapping\s+-\s+/, _substr_begin)
		_substr = _deps_raw.slice(_substr_begin .. _substr_end - 1)
		
		@deps_fqn_list = []
		_substr.delete! ' |'
		_substr.each_line do |line|
			if line[/^(\\|\+|\|){1}-+.*?/]
				_updated_line = line.gsub(/^(\\|\+|\|){1}-+/, '').gsub(/\(\*\)/, '').gsub(/\n/, '')
				@deps_fqn_list.push(_updated_line)
			end
		end

		# the first entry is the requested library
		@library_fqn = deps_fqn_list[0]
		@deps_fqn_list.delete_at(0)
	end
end

if __FILE__ == $0
	init_gradle_files
	inject_library_name "com.github.dextorer:sofa:1.0.0"
	c = ComputeDependencies.new
	c.fetch_dependencies
	puts c.library_fqn
	puts c.deps_fqn_list
	restore_workspace
end