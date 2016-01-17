class AnalyticsService
  include HTTParty
  base_uri 'www.google-analytics.com'

  TRACKING_ID='UA-72547706-1'
  CLIENT_ID=42

  def self.hit(ip, user_agent, path)
    options = {
      body: {
        v: 1,
        tid: TRACKING_ID,
        cid: 42,
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
