module GradleService
  extend self

  def get_deps(library_name)
  	gradle_env_dir = "gradle_env"

    result = `#{gradle_env_dir}/gradlew -p #{gradle_env_dir} -q deps -PinputDep=#{library_name}`

    if $?.exitstatus != 0
      raise "Error while calculating dependencies with Gradle"
    end

    Dep.from_gradle_output(result)
  end

end
