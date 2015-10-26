require 'rubygems'
require 'nokogiri'
require 'open-uri'

require './library_methods_count'

class AndroidArsenalParser 

	def initialize(page_start, page_end)
		@base_url = "http://android-arsenal.com"
		@rating_path = "/rating?page="

		@page_start = page_start
		@page_end = page_end
	end

	def parse
		start_index = @page_start
		end_index = @page_end

		libs_urls = []

		while start_index <= end_index do
			page = Nokogiri::HTML(open("#{@base_url}#{@rating_path}#{start_index}"))
			hrefs = page.css('body div.container.content div.color-panel-header a')
			hrefs.each do |item|
				next if item["href"].start_with?("/user")
				
				url = item["href"]
				libs_urls.push("#{@base_url}#{url}")
			end

			start_index = start_index + 1
		end

		compile_statements = []
		libs_urls.each do |lib_url|
			lib_page = Nokogiri::HTML(open(lib_url))
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

						begin
				    		LibraryMethodsCount.new(powermatch).compute_dependencies()
				  		rescue
				    		puts "Error, skipping"
				  		end
					}
				}
			end
		end

		return compile_statements
	end

end

if __FILE__ == $0
	parser = AndroidArsenalParser.new(1, 63)
	compile_statements = parser.parse
end