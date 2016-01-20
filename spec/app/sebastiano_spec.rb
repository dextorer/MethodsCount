require "spec_helper"

describe Sebastiano do
  include Rack::Test::Methods  #<---- you really need this mixin

  def app
    Sebastiano
  end

  def stub_analytics_request
    stub_request(:post, "http://www.google-analytics.com/collect")
  end

  describe "POST request" do
    before do
      allow_any_instance_of(LibraryMethodsCount).to receive(:compute_dependencies).and_return
    end

    it "sends ip and user agent to GA" do
      stub_analytics_request.
        with(:body => "v=1&tid=UA-72547706-1&cid=f528764d624db129b32c21fbca0cb8d6&t=pageview&uip=127.0.0.1&ua=TestRunner&dp=%2Fapi%2Frequest",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})

      post "/api/request/test_lib", {}, {'HTTP_USER_AGENT' => 'TestRunner'}
    end

    describe 'logger' do
      before do
        @logger = object_double("LOGGER", :error => nil).as_stubbed_const
      end

      it "logs an error if GA returns an error" do
          stub_analytics_request.
            to_return(:status => 500, :body => "Big error", :headers => {})

        post "/api/request/test_lib"

        expect(@logger).to have_received(:error).with(/Big error/)
      end

      it "logs an error if GA request experience network failures" do
        stub_analytics_request.to_timeout

        post "/api/request/test_lib"

        expect(@logger).to have_received(:error).with(/An error occurred while submitting/)
      end

      it "logs an error if GA request throws errors" do
        stub_analytics_request.to_raise(StandardError)

        post "/api/request/test_lib"

        expect(@logger).to have_received(:error).with(/An error occurred while submitting/)
      end
    end
  end
end
