require 'pry-byebug'
require 'httparty'
require 'watir'
require 'active_support'
require 'nokogiri'
require 'colorize'
require 'rubyXL'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'
require "selenium-webdriver"
require_relative './scrapers/bizi'
require_relative './scrapers/pirs'


def row_processed?(row)
  row[8].value.to_i == 1 ||
      !row[6].value.nil?
end

def unprocessed_rows(worksheet)
  worksheet
      .rows
      .drop(1)
      .reject { |r| row_processed?(r) }
end

def save_workbook(workbook)
  puts 'Saving workbook...'.yellow
  workbook.write('138-139k_2.xlsx')
  puts 'Workbook saved'.green
end

def scrape(workbook)
  worksheet = workbook[0].sheet_data
  unprocessed_rows(worksheet).each do |row|
    Scrapers::Bizi.scrape(row)

    sleep(3)
  end
end

workbook = RubyXL::Parser.parse("138-139k_2.xlsx")
begin
  scrape(workbook)
  save_workbook(workbook)
rescue StandardError => e
  puts e.message
  save_workbook(workbook)
rescue SystemExit, Interrupt
  save_workbook(workbook)
end