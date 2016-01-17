require "spec_helper"

describe Sebastiano do
  include Rack::Test::Methods  #<---- you really need this mixin

  def app
    Sebastiano
  end

  describe "POST request" do
    it "sends ip and user agent to GA" do
      allow_any_instance_of(LibraryMethodsCount).to receive(:compute_dependencies).and_return
      stub_request(:post, "http://www.google-analytics.com/collect").
         with(:body => "v=1&tid=UA-72547706-1&cid=42&t=pageview&uip=127.0.0.1&ua=TestRunner",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "", :headers => {})

      post "/api/request/test_lib", {}, {'HTTP_USER_AGENT' => 'TestRunner'}
    end
  end
end
