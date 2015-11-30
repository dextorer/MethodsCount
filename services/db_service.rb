module DBService
  extend self

  def connected?
    begin
      ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }
    rescue
      false
    end

    true
  end

end
