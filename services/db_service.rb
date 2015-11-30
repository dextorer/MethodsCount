module DBService
  extend self

  def connected?
    begin
      ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }
    rescue Exception => e
      LOGGER.error e.message
      return false
    end

    return true
  end

end
