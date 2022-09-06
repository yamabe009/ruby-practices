#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

COLUMN_WIDTH = 8
FULL_OPTIONS = {
  l: true,
  w: true,
  c: true
}.freeze

def main
  options = {}
  opt = OptionParser.new
  opt.on('-l') { |v| options[:l] = v }
  opt.on('-w') { |v| options[:w] = v }
  opt.on('-c') { |v| options[:c] = v }
  files = opt.parse(ARGV)

  options = FULL_OPTIONS if options.empty?
  rows = files.empty? ? [calc_text(options, $stdin.read)] : calc_files(options, files)
  puts format(options, rows)
end

def calc_files(options, files)
  result = files.map do |filepath|
    text = File.open(filepath).read
    calc_text(options, text, title: filepath)
  end
  result.push total(options, result) if files.count > 1
  result
end

def calc_text(options, text, title: '')
  result = {}
  result[:l] = text.count("\n") if options[:l]
  result[:w] = text.split("\s").count if options[:w]
  result[:c] = text.bytesize if options[:c]
  result[:title] = title
  result
end

def total(options, rows)
  result = {}
  options.each_key do |key|
    result[key] = rows.sum { |row| row[key] } if options[key] && key != :title
  end
  result[:title] = 'total'
  result
end

def format(options, rows)
  rows.map do |row|
    result = ''
    options.each_key { |key| result += row[key].to_s.rjust(COLUMN_WIDTH) if options[key] }
    result += " #{row[:title]}"
  end
end

main
