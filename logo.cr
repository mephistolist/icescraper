require "http/client"
require "option_parser"
require "colorize"
require "set"

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

        break unless response && (300..399).includes?(response.status_code) # Don't follow redirects

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
    #puts "Parsing page: #{html.size} bytes"
    links = extract_links(html).map { |link| link.gsub(",", "\n") }
    puts "Extracted links:\n#{links.join("\n ")}"
  end

  private def extract_links(html)
    links = html.scan(/href="([^"]+)"/).map { |match| match[0] }
    links.uniq.map { |link| link.split('"')[1] }
  end
end

def print_help
  logo = " .___                      _________                                               
|   |  ____   ____       /   _____/  ____ _______ _____   ______    ____ _______  
|   |_/ ___\\_/ __ \\      \\_____  \\ _/ ___ \\_  __ \\\\__  \\  \\____ \\ _/ __ \\\\_  __ \\ 
|   |\\  \\___\\  ___/      /        \\\\  \\___ |  | \\/ / __ \\_|  |_> >\\  ___/ |  | \\/ 
|___| \\___  >\\___  >    /_______  / \\___  >|__|   (____  /|   __/  \\___  >|__|    
          \\/     \\/             \\/      \\/             \\/ |__|         \\/
"       
  puts logo.colorize(:blue)
  puts "Usage: spider -d https://example.com"
  puts "Options:"
  puts "  -h, --help: Show help message"
  puts "  -d, --domain DOMAIN: Specify a domain or host"
  puts "  -o, --output: Path to file where urls are saved"
end

# Parse command line options
option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: spider [options] start_url"
  
  parser.on("-h", "--help", "Show help message") do
    print_help
    exit
  end
end

# Parse the command line arguments
begin
  args = option_parser.parse
rescue
  print_help
  exit
end

# Check if a start_url is provided
if args && args.size == 1
  start_url = args[0]
  spider = Spider.new(start_url)
  spider.crawl
else
  print_help
  exit
end
