require 'net/http'
require 'json'
require 'yaml'
require 'csv'

OPENAI_API_ENDPOINT = URI('https://api.openai.com/v1/chat/completions')

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
  # TODO: config to ask user for the input
  config = load_config
  log_dir = config['log_dir']
  session_catalog = config['session_catalog']
  openai_api_key = config['openai_api_key']
  prompt = config['prompt']

  if log_dir.nil?
    print "Enter the log directory: "
    log_dir = gets.chomp
    config['log_dir'] = log_dir
  end

  if session_catalog.nil?
    print "Enter the session catalog path: "
    session_catalog = gets.chomp
    config['session_catalog'] = session_catalog
  end

  if openai_api_key.nil?
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
  api_key = load_api_key

  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  body = {
    model: 'gpt-3.5-turbo',
    messages: [
             { role: 'system', content: 'You are a programmer and UNIX system and terminal master. You understand every command emmaculately and can articulate what terminal commands do a high and concise level. Do not use any redundancy in how you speak. Be clear and straight to the point. You have a keen perception for ANSI escape codes' },
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

env_check

# TODO: some kind of checking to make sure it works
invoke_script
