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

    begin
      response = HTTP::Client.get(url)

      if response.success?
        parse_page(response.body.to_s)

        @visited_urls << url

        # Extract links and crawl them
        links = extract_links(response.body.to_s)
        links.each { |link| crawl_page(link) }
      else
        puts "Failed to fetch #{url} - #{response.status_code}"
      end
    rescue Socket::Addrinfo::Error
      puts "Failed to lookup hostname for #{url}"
    end
  end

  private def parse_page(html)
    #puts "Parsing page: #{html.size} bytes"
    links = extract_links(html).map { |link| link.gsub(",", "\n") }
    puts "Extracted links:\n#{links.join("\n ")}"  
  end

  private def extract_links(html)
    links = html.scan(/<a[^>]*href=["'](https?:\/\/[^"']+)["'][^>]*>/).map { |match| match[0] }
    links.uniq
  end
end

# Example usage
spider = Spider.new("https://www.google.com")
spider.crawl
