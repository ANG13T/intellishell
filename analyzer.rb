require 'net/http'
require 'json'
require 'yaml'
require 'csv'

OPENAI_API_ENDPOINT = URI('https://api.openai.com/v1/chat/completions')

def show_options
  puts "1. Record Session"
  puts "2. Display Logs"
  puts "3. Search Logs"
  puts "4. Delete Log"
  puts "5. Exit"
end

def choose_option
  print "Choose an option: "
  gets.chomp.to_i
end

def main
  show_options
end

# Loads API Key from YAML config file
def load_api_key
  config = YAML.load_file('config.yaml')
  config['openai_api_key']
end

def load_config
  config = YAML.load_file('config.yaml')
  config
end

def save_config(config)
  File.open('config.yaml', 'w') { |file| YAML.dump(config, file) }
end

def env_check
  config = load_config
  log_dir = config['log_dir']
  session_catalog = config['session_catalog']
  openai_api_key = config['openai_api_key']
  prompt = config['prompt']

  if log_dir == "path/to/log/directory" || log_dir.nil?
    print "Enter the log directory: "
    log_dir = gets.chomp
    config['log_dir'] = log_dir
  end

  if session_catalog == "path/to/session_catalog.csv" || session_catalog.nil?
    print "Enter the session catalog path: "
    session_catalog = gets.chomp
    config['session_catalog'] = session_catalog
  end

  if openai_api_key == "your_openai_api_key" || openai_api_key.nil?
    print "Enter the OpenAI API key: "
    openai_api_key = gets.chomp
    config['openai_api_key'] = openai_api_key
  end

  if prompt.nil?
    print "Enter the prompt: "
    prompt = gets.chomp
    config['prompt'] = prompt
  end

  save_config(config)

  # check if session catalog exists as a file
  unless File.exist?(session_catalog)
    puts "Session catalog CSV file does not exist: #{session_catalog}"
    exit 1
  end
end

def invoke_script()
  config = load_config
  logging_dir = config['log_dir']
  session_path = config['session_catalog']

  # create the timestamp to feed into the script
  timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
  shell_script = './logger.sh'
  system("#{shell_script} #{logging_dir} #{session_path} #{timestamp}")
  analyze_terminal_code("#{logging_dir}/#{timestamp}/session.txt", "#{logging_dir}/#{timestamp}/summary.txt", timestamp)
end

# Function to interact with ChatGPT
def ask_chatgpt(question, terminal_input)
  config = load_config
  prompt = config['prompt']
  api_key = load_api_key

  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  body = {
    model: 'gpt-3.5-turbo',
    messages: [
             { role: 'system', content: prompt },
             { role: 'user', content: "#{question} Terminal session: #{terminal_input}"}
           ],
    max_tokens: 150
  }.to_json

  http = Net::HTTP.new(OPENAI_API_ENDPOINT.host, OPENAI_API_ENDPOINT.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(OPENAI_API_ENDPOINT.path, headers)
  request.body = body

  response = http.request(request)

  if response.code.to_i == 200
    response_data = JSON.parse(response.body)
    if response_data['choices'] && response_data['choices'][0] && response_data['choices'][0]['message']
      return response_data['choices'][0]['message']['content'].strip
    else
      raise "Unexpected response structure: #{response.body}"
    end
  else
    raise "Error interacting with OpenAI API: #{response.code} - #{response.body}"
  end
end

def read_file(file_path)
  contents = ""
  # Open the file for reading
  File.open(file_path, "r") do |file|
    # Print each line of the file
    file.each_line do |line|
      contents += line
    end
  end
  contents
end

def analyze_terminal_code(path, summary_path, timestamp)

  terminal_contents = read_file(path)

  begin
    # Send input to ChatGPT
    response_summary = ask_chatgpt("Interpret this terminal session and describe what the user is doing in a few sentences", terminal_contents)
    response_title = ask_chatgpt("Interpret this terminal session and describe what the user is doing in one concise summary sentence", terminal_contents)
    save_summary(summary_path, response_title, response_summary, timestamp)
    save_to_catalog(timestamp, response_title, response_summary, path)
    puts "Terminal Session Saved: #{path}"
  rescue => e
    puts "Error: #{e.message}"
  end

end

def save_summary(summary_path, title, summary, timestamp)
  # Save the summary to a file
  File.open(summary_path, 'w') { |file| file.write("TITLE: #{title} \n\nTIMESTAMP: #{timestamp}\n\nSUMMARY: #{summary}") }
end

# Saves the session to a CSV file
# Timestamp, Path, Summary, Description
def save_to_catalog(timestamp, title, summary, path)
  # write the the sessions.csv file and log the terminal entry
  session_entry = [timestamp, path, title, summary]
  session_catalog = load_config['session_catalog']
  headers = ['Timestamp', 'Path', 'Title', 'Summary']

  file_empty = File.zero?(session_catalog)

  CSV.open(session_catalog, 'a+') do |csv|
    # Write headers if the file does not exist or is empty
    if file_empty
      csv << headers
    end

    csv << session_entry
  end
end

def record
  env_check
  invoke_script
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

def banner
  puts "IntelliShell [v.1r0] - AI Terminal Session Analyzer"
  puts "URL: https://github.com/ANG13T/IntelliShell"
  puts "---------------- By G4LXY -------------------"
end

def main
  banner
  loop do
    display_menu
    choice = choose_option

    case choice
    when 1
      record
    when 2
      display_logs
    when 3
      print "Enter search term: "
      search_term = gets.chomp
      search_logs(search_term)
    when 4
      print "Enter timestamp to delete: "
      timestamp = gets.chomp
      delete_log(timestamp)
    when 5
      break
    else
      puts "Invalid choice"
    end
  end
end

main