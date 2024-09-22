require "http/client"
require "option_parser"
require "colorize"
require "uri"

class Spider
  @start_url : String
  @base_url : URI

  def initialize(@start_url : String)
    @visited_urls = Set(String).new

    # Parse the URL and handle possible nil values for scheme and host
    parsed_uri = URI.parse(@start_url)
    scheme = parsed_uri.scheme || "http" # Default to "http" if scheme is nil
    host = parsed_uri.host

    if host.nil?
      raise "Invalid URL: Missing host part in #{@start_url}"
    end

    # Store base_url as a URI for later use
    @base_url = URI.parse("#{scheme}://#{host}")
  end

  def crawl
    crawl_page(@start_url)
  end

  private def crawl_page(url)
    return if @visited_urls.includes?(url)

    begin
      response = HTTP::Client.get(url)

      if response.success?
        body = String.new(response.body.to_s.encode("UTF-8", invalid: :skip))
        parse_page(body, url)
        @visited_urls << url

        # Extract and print only the URLs
        links = extract_links(body)
        links.each { |link| puts link } # This prints only the URLs, no href.
      else
        puts "Failed to fetch #{url} - #{response.status_code}"
      end
    rescue Socket::Addrinfo::Error
      puts "Failed to lookup hostname for #{url}"
    rescue ex
      puts "An unexpected error occurred: #{ex.message}"
    end
  end

  private def parse_page(html, url)
    # Just print the links (cleaned) instead of crawling them
    links = extract_links(html)
    puts "Links found on #{url}:\n#{links.join("\n")}"
  end

  private def extract_links(html)
    html.scan(/href="([^"]+)"/).flat_map { |match|
      match[0].split(/(?=https?:\/\/)/).map do |url|
        if url.starts_with?("http://") || url.starts_with?("https://")
          url
        else
          # Manually join relative URL to base URL
          join_url(@base_url, url)
        end
      end
    }
  end

  # Helper method to join a base URL with a relative path
  private def join_url(base_uri : URI, relative_url : String) : String
    base_uri = base_uri.dup
    base_uri.path = File.join(base_uri.path || "/", relative_url) # Join the base and relative paths
    base_uri.to_s
  end
end

def print_logo
  logo = " .___                      _________                                               
|   |  ____   ____       /   _____/  ____ _______ _____   ______    ____ _______  
|   |_/ ___\\_/ __ \\      \\_____  \\ _/ ___ \\_  __ \\\\__  \\  \\____ \\ _/ __ \\\\_  __ \\ 
|   |\\  \\___\\  ___/      /        \\\\  \\___ |  | \\/ / __ \\_|  |_> >\\  ___/ |  | \\/ 
|___| \\___  >\\___  >    /_______  / \\___  >|__|   (____  /|   __/  \\___  >|__|    
          \\/     \\/             \\/      \\/             \\/ |__|         \\/
"       
  puts logo.colorize(:blue)
end

# Define the code to run after displaying the logo
def run_after_logo(domain)
  print_logo
  scheme = domain.starts_with?("http://") || domain.starts_with?("https://") ? "" : "https://"
  spider = Spider.new("#{scheme}#{domain}")
  spider.crawl
end

# Parse command line options
option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: icescraper -d example.com"
  
  parser.on("-h", "--help", "Show help message") do
    print_logo
    puts parser # Display the usage information
    exit
  end

  parser.on("-d", "--domain DOMAIN", "Specify a domain or host. Use http:// if no SSL is used.") do |domain|
    run_after_logo(domain)
    exit
  end
end

# Parse the command line arguments
begin
  args = option_parser.parse
rescue
  print_logo
  puts option_parser # Display the usage information
  exit
end

# Check if a start_url is provided
if args && args.size == 1
  start_url = args[0]
  puts "Start URL specified: #{start_url}"
else
  print_logo
  puts option_parser # Display the usage information
  exit
end
