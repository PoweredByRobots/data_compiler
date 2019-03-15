# Takes pertinent data from a live log file
# and writes it to another file

class Hits
  def initialize(input, output)
    @hits = []
    @input = input
    @output = output
  end

  def latest
    input.each { |i| @hits << check_input(i) }
    @hits.uniq.compact
  end

  private

  def check_input(input)
    return if input_exists?(input)
    input
  end

  def input_exists?(input)
    output.any? { |o| input.include? o }
  end
end

def input_file
  '/home/you/log_log.log'
end

def output_file
  '/home/you/pertinent_data.log'
end

def input_regex
  /pertinent data coming up (.*?) told ya/m
end

def output_regex
  /(?<=. ).*/
end

def matching_lines_to_array(file, regex)
  lines = File.readlines(file)
  hits = []
  lines.each do |line|
    next unless potential_hit?(line)
    next unless line.match?(regex)
    hits << (line[regex, 1] || line[regex])
  end
  hits
end

def the_data_you_are_looking_for
  /(steak|meat|cheese|kale|baby dill)/
end

def potential_hit?(line)
  line.match?(the_data_you_are_looking_for)
rescue
  false
end

def next_number
  @next_number ||= number_from_file
end

def number_from_file
  last_line = File.readlines(output_file).last
  number = last_line[/^[^\.]*/].to_i + 1
  number > 15 ? 1 : number
end

def append_to_output_file(entries)
  File.open(output_file, 'a') do |file|
    entries.each do |entry|
      entry = next_number.to_s + '. ' + entry
      puts "Adding #{entry}"
      file.puts entry
      @next_number += 1
      @next_number = 1 if @next_number > 15
    end
  end
end

def pause
  sleep 1800 # half an hour
end

loop do
  input_entries = matching_lines_to_array(input_file, input_regex)
  output_entries = matching_lines_to_array(output_file, output_regex)
  append_to_output_file(Hits.new(input_entries, output_entries).latest)
  pause
end
