require 'fileutils'

class SdkService
  
  LOGGER_TAG = "[LibraryMethodsCount]"

  def initialize(artifact_id, workspace)
    @artifact_id = artifact_id
    @workspace = workspace

    ENV['DX_PATH'].to_s.tap do |path|
      @dx_path = path + '/dx' unless path.empty?
      @dx_path ||= 'dx'
    end
  end


  def self.open_workspace(artifact_id)
  	# calculate methods count for new dependencies
  	rand = Random::DEFAULT.rand().to_s
    Dir.mkdir(rand)
    workspace = File.absolute_path(rand)
    service = SdkService.new(artifact_id, workspace)
    
    begin
      yield service
    ensure
      FileUtils.rm_r(workspace)
    end
  end


  def dex(file_path)
    # build DEX file

    if not File.exists?(file_path)
      error_msg = "Target #{file_path} does not exist"
      log('error', error_msg)
      raise error_msg
    end

    tmp_dex_path = "#{@workspace}/tmp.dex"
    begin
      Timeout::timeout(2 * 60) do # 2 minutes
        dx_command = "#{@dx_path} --dex --output=#{tmp_dex_path} #{file_path}" 
        log('debug', "exec: #{dx_command}")
        system(dx_command)
        dx_result = $?.exitstatus
        if dx_result != 0
          # some libraries require the --core-library flag, try again
          dx_command = "#{@dx_path} --dex --core-library --output=#{tmp_dex_path} #{file_path}" 
          log('debug', "[fallback] exec: #{dx_command}")
          system(dx_command)
        end
      end
    rescue Timeout::Error
      raise "'dx' operation timed out, invalidating current library"
    end

    dx_result = $?.exitstatus
    if dx_result == 0
      log('debug', "DXed successfully (result code: #{dx_result})")
    else
      log('error', "Could not create DEX for #{file_path}")
      raise "Could not create DEX for #{file_path}"
    end

    count = deps_count(tmp_dex_path)
    dex_size = File.size(tmp_dex_path)

    [count, dex_size]
  end


  def get_jar(file_path)
    jar_path = file_path
    
  	is_aar = file_path.end_with?(".aar")
    log('debug', "Format: #{is_aar ? 'AAR' : 'JAR'}")

    if is_aar
      # extract AAR's classes.jar
      system("unzip -q #{file_path} -d #{@workspace} classes.jar")
      if File.exists?(path('classes.jar'))
        jar_path = path('classes.jar')
      end
    end

    return jar_path if class_file_exists?(jar_path)
  end


  def class_file_exists?(jar)
    # make sure our jar actually contains .class files :)
    exist = true
    `unzip -l #{jar} | grep -x .*\.class$`
    if $?.exitstatus != 0
      exist = false
      log('debug', "Empty JAR file (no .class files found), consider as res-only")
    end

    exist
  end


  private


  def log(level, message)
    LOGGER.send(level, "#{LOGGER_TAG} [#{@artifact_id}] #{message}")
  end


  def deps_count(dex_path)
    `cat #{dex_path} | head -c 92 | tail -c 4 | hexdump -e '1/4 "%d\n"'`.to_i
  end


  def path(file_name)
    "#{@workspace}/#{file_name}"
  end
end
