require 'net/http'
require 'json'
require 'yaml'

OPENAI_API_ENDPOINT = URI('https://api.openai.com/v1/chat/completions')

# Check if the correct number of arguments is provided
if ARGV.length != 2
  puts "Usage: ruby analyzer.rb <log_directory> <session_path>"
  exit 1
end

# Loads API Key from YAML config file
def load_api_key
  config = YAML.load_file('config.yaml')
  config['openai_api_key']
end

# Function to interact with ChatGPT
def ask_chatgpt(prompt)
  api_key = load_api_key

  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  body = {
    model: 'gpt-3.5-turbo',
    messages: [
             { role: 'system', content: 'You are a programmer and UNIX system and terminal master. You understand every command emmaculately and can articulate what terminal commands do a high and concise level. Do not use any redundancy in how you speak. Be clear and straight to the point. You have a keen perception for ANSI escape codes' },
             { role: 'user', content: "Interpret this terminal session and describe what the user is doing in a few sentences and one summarizing sentence. For the one short summary sentence, surround it in parenthesis. Terminal session: #{prompt}"}
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

def analyze_terminal_code
  log_file = ARGV[0]

  terminal_contents = read_file(log_file)

  begin
    # Send input to ChatGPT
    response = ask_chatgpt(terminal_contents)
    puts "ChatGPT says: #{response}"
  rescue => e
    puts "Error: #{e.message}"
  end
end

# Saves the session to a CSV file
# Timestamp Start, Amount of Time in Session,  Path, Summary, Description
def save_to_catalog
  catalog_file = ARGV[1]
end

analyze_terminal_code if __FILE__ == $0
