require "option_parser"
require "colorize"

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
  puts "Running something else with domain: #{domain}"
end

# Parse command line options
option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: icescraper -d https://example.com"
  
  parser.on("-h", "--help", "Show help message") do
    print_logo
    puts parser # Display the usage information
    exit
  end

  parser.on("-d", "--domain DOMAIN", "Specify a domain or host") do |domain|
    print_logo
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
