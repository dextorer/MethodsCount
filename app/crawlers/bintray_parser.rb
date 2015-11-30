require 'rubygems'
require 'nokogiri'
require 'open-uri'

class BintrayParser 

	def initialize(page_start, page_end)
		@root_url = "https://bintray.com"
		@base_url = "https://bintray.com/search/tab/packages?sort=last_updated&username=&forceAgnostic=&repoPath=&query=android"
		@rating_path = "&offset="

		@page_start = page_start
		@increment_factor = 12
		@page_end = page_end
	end

	def parse
		start_index = @page_start * @increment_factor
		end_index = @page_end * @increment_factor

		compile_statements = []
		libs_urls = []
		
		while start_index < end_index do
			begin
				LOGGER.info "Processing: #{start_index}"
				begin
					page = Nokogiri::HTML(open("#{@base_url}#{@rating_path}#{start_index}"))
				rescue
					next
				end
				hrefs = page.css('#searchResultsPackage div ul li.small.thumb-container div div.thumb a')
				hrefs.each do |item|
					next if item["href"].start_with?("/user")
					
					url = item["href"]
					real_url = "#{@root_url}#{url}"

					begin
						inner_page = Nokogiri::HTML(open(real_url))
					rescue
						LOGGER.error "Inner page error with " + real_url
						next
					end
					website_links = inner_page.css("#about div.content.table div[data-id='vcs'] div.td.value a")
					website_links.each do |inner_item|
						final_url = inner_item["href"]

						libs_urls.push("#{final_url}")
					end
				end

				libs_urls.each do |lib_url|
					begin
						lib_page = Nokogiri::HTML(open(lib_url))
					rescue
						LOGGER.error "Error opening page" + lib_url
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
								LOGGER.info powermatch
								compile_statements.push(powermatch)
							}
						}
					end
				end
			rescue
				LOGGER.error "General error"
				next
			ensure
				start_index = start_index + @increment_factor
				libs_urls.clear
			end
		end

		return compile_statements
	end

end
