require "http/client"
require "option_parser"
require "colorize"
require "set"

class Scraper
  @start_url : String

  def initialize(@start_url : String)
    # preserved for future options
  end

  def scrape
    current = @start_url
    response = nil

    5.times do
      response = HTTP::Client.get(current)
      break unless response && (300..399).includes?(response.status_code)

      loc = response.headers["Location"]
      break unless loc
      current = resolve_relative(loc, current)
    end

    if response
      if response.success?
        html = String.new(response.body.to_slice, "UTF-8", :skip)
        puts "Fetched #{current}: #{response.status_code}, #{response.body.size} bytes"
        parse_page(html, current)
      else
        puts "Failed to fetch #{current} - #{response.status_code}"
      end
    else
      puts "Failed to fetch #{current} - No response"
    end
  rescue Socket::Addrinfo::Error
    puts "Failed to lookup hostname for #{current}"
  rescue ex
    if ex.message =~ /Timeout/
      puts "Timed out while fetching #{current}"
    else
      puts "An unexpected error occurred: #{ex.message}"
    end
  end

  private def parse_page(html : String, base : String)
    links = extract_links(html, base)
    puts "Extracted links:"
    links.each { |l| puts " #{l}" }
  end

  # Extract href values and return normalized absolute URLs (Array(String))
# Replace your current extract_links with this function
private def extract_links(html : String, base : String) : Array(String)
  captures = html.scan(/href\s*=\s*["']([^"']+)["']/i).map { |m| m[0] }
  urls = Array(String).new

  captures.each do |raw|
    next if raw.nil? || raw.blank?
    link = raw.to_s.strip

    # Defensive cleaning: remove stray 'href=' fragments and surrounding quotes
    link = link.gsub(/\Ahref\s*=\s*/i, "")                 # leading href=
    link = link.gsub(/\Ahttps?:\/\/\s*href\s*=\s*/i, "")  # leading https://href= or http://href=
    link = link.gsub(/\A['"]+/, "").gsub(/['"]+\z/, "")    # remove surrounding quotes

    # fix common typo: 'ttps://' or 'ttp://' -> add missing 'h'
    if link.starts_with?("ttps://") || link.starts_with?("ttp://")
      link = "h" + link
    end

    lc = link.downcase
    # Skip javascript/mailto/anchors
    next if lc.starts_with?("javascript:") || lc.starts_with?("mailto:") || link.starts_with?("#")

    # If href contains embedded http(s) URLs, extract and add them separately
    embedded_raw = begin
      link.scan(/https?:\/\/[^"'\s<>]+/i)
    rescue
      [] of String
    end

    if embedded_raw.size > 0
      embedded_raw.each do |e|
        url_str = e.is_a?(Regex::MatchData) ? e[0].to_s : e.to_s
        urls << normalize(url_str, base)
      end
      next
    end

    # Protocol-relative: //example.com/path
    if link.starts_with?("//")
      m = base.match(/^(https?:)/)
      scheme = m ? m[1] : "https:"
      urls << normalize("#{scheme}#{link}", base)
      next
    end

    # Absolute http(s)
    if link.starts_with?("http://") || link.starts_with?("https://")
      urls << normalize(link, base)
      next
    end

    # Root-relative /path -> origin + path (ensure we removed leading quotes)
    if link.starts_with?("/")
      m = base.match(/^(https?:\/\/[^\/]+)/)
      origin = m ? m[1] : base
      # remove any leftover leading quotes just in case
      cleaned = link.gsub(/\A['"]+/, "")
      urls << normalize(origin + cleaned, base)
      next
    end

    # Relative path (no leading slash) -> resolve against base directory
    base_dir = base.sub(/\?.*$/, "")
    idx = base_dir.rindex("/")
    base_dir = idx ? base_dir[0, idx + 1] : base_dir + "/"
    urls << normalize(base_dir + link, base)
  end

  # Final safety: split entries that accidentally still contain multiple http(s) targets
  final = Array(String).new
  urls.each do |u|
    parts = begin
      # split on each occurrence of http:// or https:// without dropping the prefix
      u.split(/(?=https?:\/\/)/i)
    rescue
      [] of String
    end

    parts.each do |p|
      next if p.nil? || p.blank?

      # p may be a MatchData or String depending on Crystal version
      part = p.is_a?(Regex::MatchData) ? p[0].to_s : p.to_s
      part = part.strip

      # --- 1) If the part contains multiple '://', drop the first scheme + '://'
      if part.count("://") > 1
        first = part.index("://") || 0
        # keep everything after the first '://'
        part = part[(first + 3)..-1].to_s
        part = part.strip
      end

      # --- 2) If we have a scheme + single token with no dot or slash (e.g. https://ebooks),
      # treat it as a relative path on the base origin: origin + "/ebooks"
      if part =~ /^https?:\/\/[A-Za-z0-9\-_]+$/
        m = base.match(/^(https?:\/\/[^\/]+)/)
        origin = m ? m[1] : base
        # extract the token after the scheme://
        token = part.sub(/^https?:\/\//i, "")
        part = origin + "/" + token
      end

      # --- 3) Ensure we only keep a clean first URL-like match inside part
      # (handles trailing garbage)
      first_match = begin
        part.match(/https?:\/\/[^"'\s<>]+/i)
      rescue
        nil
      end

      if first_match
        final << normalize(first_match[0].to_s, base)
      else
        # If there's no http(...), it might be a relative path already (keep it)
        final << normalize(part.strip, base)
      end
    end
  end

  final.uniq
end

  private def normalize(url : String, _base : String) : String
    url.strip
  end

  private def resolve_relative(loc : String, base : String) : String
    l = loc.strip
    return l if l.starts_with?("http://") || l.starts_with?("https://")
    if l.starts_with?("/")
      m = base.match(/^(https?:\/\/[^\/]+)/)
      origin = m ? m[1] : base
      return origin + l
    end

    base_dir = base.sub(/\?.*$/, "")
    idx = base_dir.rindex("/")
    base_dir = idx ? base_dir[0, idx + 1] : base_dir + "/"
    base_dir + l
  end
end

# ---------- UI and option parsing ----------
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

def run_after_logo(domain : String)
  print_logo
  puts "Starting scraper for #{domain}"
  scheme = domain.starts_with?("http://") || domain.starts_with?("https://") ? "" : "https://"
  scraper = Scraper.new("#{scheme}#{domain}")
  scraper.scrape
end

# option parsing
domain_arg : String? = nil

option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: icescraper -d example.com"

  parser.on("-h", "--help", "Show help message") do
    print_logo
    puts parser
    exit
  end

  parser.on("-d", "--domain DOMAIN", "Specify a domain or host.") do |d|
    domain_arg = d
  end
end

begin
  _ = option_parser.parse
rescue
  print_logo
  puts option_parser
  exit
end

if domain_arg
  run_after_logo(domain_arg.not_nil!)
else
  print_logo
  puts option_parser
  exit
end
