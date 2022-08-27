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
  wc_data = files.empty? ? [wc_text(options, $stdin.read)] : wc_files(options, files)
  puts format(options, wc_data)
end

def wc_files(options, files)
  result = files.map do |filepath|
    text = File.open(filepath).read
    wc_text(options, text, content: filepath)
  end
  result.push total(options, result) if files.count > 1
  result
end

def wc_text(options, text, content: '')
  result = {}
  result[:l] = text.count("\n") if options[:l]
  result[:w] = text.split("\s").count if options[:w]
  result[:c] = text.bytesize if options[:c]
  result[:content] = content
  result
end

def total(options, wc_data)
  result = {}
  options.each_key do |key|
    result[key] = wc_data.sum { |data| data[key] } unless key == :content
  end
  result[:content] = 'total'
  result
end

def format(options, wc_data)
  wc_data.map do |data|
    result = ''
    options.each_key { |key| result += data[key].to_s.rjust(COLUMN_WIDTH) if options[key] }
    result += " #{data[:content]}"
  end
end

main
