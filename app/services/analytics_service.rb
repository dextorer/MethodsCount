require 'open-uri'
require 'digest'

class AnalyticsService
  include HTTParty
  base_uri 'www.google-analytics.com'

  TRACKING_ID='UA-72547706-1'

  def self.hit(ip, user_agent, path)
    client_id = Digest::MD5.new.update(ip)
    options = {
      body: {
        v: 1,
        tid: TRACKING_ID,
        cid: client_id,
        t: 'pageview',
        uip: ip,
        ua: user_agent,
        dp: path
      }
    }

    begin
      response = post('/collect', options)
      if response.code / 100 == 5
        LOGGER.error "GA exception: #{response}"
      end
    rescue => e
      LOGGER.error "An error occurred while submitting data to GA: #{e.message}"
    end
  end
end
