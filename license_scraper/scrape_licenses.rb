require 'bundler/inline'
require 'csv'

gemfile do
  source 'https://rubygems.org'
  gem 'typhoeus'
  gem 'nokogiri'
end

unless ARGV && ARGV.length == 2
  puts "USAGE: ruby scrape_licenses.rb <FILE> <COMMA_SEP_NUMBERS>"
  exit
end

output_file = ARGV[0]
numbers = ARGV[1].split(",")

headers = [
  'Business Info',
  'Entity',
  'Issue Date',
  'Reissue Date',
  'Expire Date'
]

puts "Scraping licenses to #{output_file}: #{numbers.inspect}"

CSV.open(output_file, 'w', write_headers: true, headers: headers) do |csv|
  numbers.each do |num|
    url = "https://www.cslb.ca.gov/onlineservices/checklicenseII/LicenseDetail.aspx?LicNum=#{num}"
    response = Typhoeus.get(url)
    doc = Nokogiri::HTML(response.body)

    # Replace br tags with commas
    doc.css('br').each{ |br| br.replace "\n" }

    csv << [
      doc.css('#MainContent_BusInfo').text,
      doc.css('#MainContent_Entity').text,
      doc.css('#MainContent_IssDt').text,
      doc.css('#MainContent_ReIssueDt').text,
      doc.css('#MainContent_ExpDt').text,
    ]
  end
end
