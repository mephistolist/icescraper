require "http/client"

class Spider
  @start_url : String

  def initialize(@start_url : String)
    @visited_urls = Set(String).new
  end

  def crawl
    crawl_page(@start_url)
  end

  private def crawl_page(url)
    return if @visited_urls.includes?(url)

    # Skip URLs that don't start with http or https
    return unless url =~ /^https?:\/\//

    begin
      response = nil

      5.times do
        response = HTTP::Client.get(url)
        
        break unless response && (300..399).includes?(response.status_code)

        url = response.headers["Location"] || url
      end

      if response
        if response.success?
          parse_page(response.body.to_s)

          @visited_urls << url

          # Extract links and crawl them
          links = extract_links(response.body.to_s)
          links.each { |link| crawl_page(link) }
        else
          puts "Failed to fetch #{url} - #{response.status_code}"
        end
      else
        puts "Failed to fetch #{url} - No response"
      end
    rescue Socket::Addrinfo::Error
      puts "Failed to lookup hostname for #{url}"
    rescue ex
      if ex.message =~ /Timeout/
        puts "Timed out while fetching #{url}"
      else
        puts "An unexpected error occurred: #{ex.message}"
      end
    end
  end

  private def parse_page(html)
    links = extract_links(html).map { |link| link.gsub(",", "\n") }
    puts "Extracted links:\n#{links.join("\n ")}"
  end

  private def extract_links(html)
    links = html.scan(/href="([^"]+)"/).map { |match| match[0] }
    links.uniq.map { |link| link.split('"')[1] }
  end
end

spider = Spider.new("https://google.com")
spider.crawl
