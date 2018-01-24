module MethodsCount
  module Routes
    class API < Sinatra::Application
      register Sinatra::Namespace
      FORMAT_SUFFIXES = ['@aar', '@jar']

      namespace '/api' do
        ## Frontend APIs ##
        get '/stats/:lib_name' do
          content_type :json
          library_name = params[:lib_name]

          library_status = LibraryStatus.where(library_name: library_name).first
          status = library_status ? library_status.status : 'undefined'
          LOGGER.info "[GET] lib status: #{status}"

          if status == 'done'
            if library_name.end_with?("+")
              LOGGER.info "[GET] ends with plus!"
              parts = library_name.split(/:/)
              library = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]]).order(version: :desc).first
            else
              library = Libraries.find_by_fqn(library_name)
            end

            # retrieve other versions
            parts = library_name.split(/:/)
            previous_libraries = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]])
                                          .order(version: :desc)
                                          .select("fqn, version, count, dex_size, id")

            result = LibraryMethodsCount.new(library.fqn).compute_dependencies()
            result.store(:previous_versions, previous_libraries)
            library.increment("hit_count")
            library.save!
          end

          {
            :status => status,
            :lib_name => library_name,
            :result => result || {}
          }.to_json
        end


        post '/request/:lib_name' do |argument|
          content_type :json
          library_name = params[:lib_name].gsub(/(#{FORMAT_SUFFIXES.join('|')})$/, '')
          
          #library_status = LibraryStatus.where(library_name: library_name).first_or_create
          ## Since the website is now in read-only mode, we don't support queueing the request any longer
          # if (library_name.end_with?("+") and library_status.updated_at < 1.week.ago) or
          #   library_status.status.to_s.empty?

          #   LOGGER.info "[POST] empty or outside time frame, calculating.."
          #   library_status.status = "processing"
          #   library_status.save!

          #   if ENV['RACK_ENV'] == 'production'
          #     QueueService.enqeue(
          #       {lib_name: library_name}
          #     )
          #   else
          #     process_library(library_name)
          #   end
          # end

          track(request, '/api/request')

          {
            :enqueued => false,
            :lib_name => library_name
          }.to_json
        end


        get '/top/' do
          content_type :json
          top = Libraries.order(hit_count: :desc).distinct(true).take(100)
          top.to_json
        end

        ## Workers APIs ##
        post '/aa' do
          content_type :json
          Thread.new do
            parser = AndroidArsenalFeedParser.new(1, 63)
            compile_statements = parser.process_feed
          end
        end


        post '/process_lib' do
          content_type :json
          request.body.rewind
          payload = JSON.parse(request.body.read)
          library_name = payload['lib_name']

          process_library(library_name)
        end
      end


      private

      def track(request, path)
        ip = request.ip
        user_agent = request.user_agent

        AnalyticsService.hit(ip, user_agent, path)
      end

      def process_library(library_name)
        lib_status = LibraryStatus.where(library_name: library_name).first
        begin
          LibraryMethodsCount.new(library_name).compute_dependencies()
          lib_status.status = "done"
        rescue Exception => e
          LOGGER.error "Failure, error is: #{e}"
          LOGGER.error "Backtrace: #{e.backtrace}"
          lib_status.status = "error"
        ensure
          lib_status.save!
        end
      end
    end
  end
end
