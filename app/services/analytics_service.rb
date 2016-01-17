class AnalyticsService
  include HTTParty
  base_uri 'www.google-analytics.com'

  TRACKING_ID='UA-72547706-1'
  CLIENT_ID=42

  def self.hit(ip, user_agent)
    options = {
      body: {
        v: 1,
        tid: TRACKING_ID,
        cid: 42,
        t: 'pageview',
        uip: ip,
        ua: user_agent
      }
    }

    post('/collect', options)
  end
end
