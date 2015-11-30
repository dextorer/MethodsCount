require 'rss'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

require_relative './library_methods_count'

class AndroidArsenalFeedParser

  def initialize(page_start, page_end)
    @feed_url = "http://feeds.feedburner.com/Android_Arsenal?format=xml"
  end

  def process_feed
    libs_urls = []
    open(@feed_url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        guid = item.guid
        url = guid.to_s[/(http:\/\/.*)</, 1]
        libs_urls.push(url)
      end
    end

    compile_statements = []
    libs_urls.each do |lib_url|
      begin
        lib_page = Nokogiri::HTML(open(lib_url))
      rescue
        LOGGER.error "Error opening page " + lib_url.to_s
        next
      end
      lib_content = lib_page.css('pre')
      lib_content.each do |node|
        compile = node.text.sub(/(.*\:.*\:.*)/) { |match|
          match = match.sub(/compile/, '')
          .sub(/debugCompile/, '')
          .sub(/releaseCompile/, '')
          .sub(/testCompile/, '')
          .sub(/classpath/, '')
          .gsub(/\s/, '')
          .gsub(/'/, '')

          match.sub(/^([a-zA-Z\d\.\-]+:[a-zA-Z\d\.\-]+:[\d\.@\+\-a-z]+)$/) { |powermatch|
            compile_statements.push(powermatch)
            LOGGER.info "[aa] lib #{powermatch}"
            begin
              LibraryMethodsCount.new(powermatch).compute_dependencies()
            rescue => e
              LOGGER.error "Fail processing #{powermatch}\nError is: #{e}\nBacktrace: #{e.backtrace}"
            end
          }
        }
      end
    end

    return compile_statements
  end

end
