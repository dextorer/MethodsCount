#/usr/bin/ruby

require 'fileutils'

$gradle_script = "build.gradle"
$gradle_script_base = "build.gradle.base"

def init_gradle_files
	FileUtils.cp("#$gradle_script_base", "#$gradle_script")
end

def inject_library_name(library_name)
	text = File.read("#$gradle_script")
	new_text = text.gsub(/dummy/, library_name)
	File.open($gradle_script, "w") {|file| file.write(new_text) }
end

def tokenize_library_fqn(library_name)
	parts = library_name.split(/:/)
end

def restore_workspace
	if File.exists?($gradle_script)
		FileUtils.rm($gradle_script)
	end
	FileUtils.rm_rf("build")
	FileUtils.rm_rf("extracted_deps")
  	init_gradle_files()
end