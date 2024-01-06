require "http/client"
require "option_parser"
require "colorize"

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
    links = extract_links(html).map { |link| link.gsub(",", "\n") }
    puts "Extracted links:\n#{links.join("\n ")}"
  end

  private def extract_links(html)
    html.scan(/href="([^"]+)"/).map { |match| match[0] }.uniq.map { |link| link.split('"')[1] }
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

  parser.on("-d", "--domain DOMAIN", "Specify a domain or host") do |domain|
    run_after_logo(domain)
    exit
  end

  parser.on("-o", "--output FILE", "Path to file where urls are saved") do |file|
    puts "THIS IS THE FILE OPTION: #{file}"
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
