require 'yaml'
require 'csv'

def load_config
  config = YAML.load_file('config.yaml')
  config
end

def display_logs
  # Load the session catalog
  session_catalog = load_config['session_catalog']

  # Read the CSV file
  CSV.foreach(session_catalog) do |row|
    puts "Timestamp: #{row[0]}"
    puts "Path: #{row[1]}"
    puts "Title: #{row[2]}"
    puts "Summary: #{row[3]}"
    puts "-----------------------------"
  end

end

def search_logs(search_term)
  # Load the session catalog
  session_catalog = load_config['session_catalog']

  puts "Search results for: #{search_term}"
  puts "----------------------------------"

  # Read the CSV file
  CSV.foreach(session_catalog) do |row|
    if row[1].include?(search_term) || row[2].include?(search_term) || row[3].include?(search_term)
      puts "Timestamp: #{row[0]}"
      puts "Path: #{row[1]}"
      puts "Title: #{row[2]}"
      puts "Summary: #{row[3]}"
      puts "-----------------------------"
    end
  end
end

def delete_log(timestamp)
  # Load the session catalog
  session_catalog = load_config['session_catalog']

  # Read the CSV file
  CSV.foreach(session_catalog) do |row|
    if row[0] == timestamp
      puts "Deleting log with timestamp: #{timestamp}"
    end
  end
end

def display_menu
  puts "1. Display Logs"
  puts "2. Search Logs"
  puts "3. Delete Log"
  puts "4. Exit"
end

def choose_option
  print "Choose an option: "
  gets.chomp.to_i
end

def main
  loop do
    display_menu
    choice = choose_option

    case choice
    when 1
      display_logs
    when 2
      print "Enter search term: "
      search_term = gets.chomp
      search_logs(search_term)
    when 3
      print "Enter timestamp to delete: "
      timestamp = gets.chomp
      delete_log(timestamp)
    when 4
      break
    else
      puts "Invalid choice"
    end
  end
end

main