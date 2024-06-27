require 'net/http'
require 'json'
require 'yaml'

OPENAI_API_ENDPOINT = URI('https://api.openai.com/v1/chat/completions')

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
             { role: 'system', content: 'You are a helpful assistant.' },
             { role: 'user', content: prompt }
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

# Main loop to analyze terminal code
def analyze_terminal_code
  puts "Welcome to Terminal Code Analyzer!"
  puts "Enter your terminal code (type 'exit' to quit):"

  loop do
    print "> "
    input = gets.chomp

    break if input.downcase == 'exit'

    begin
      # Send input to ChatGPT
      response = ask_chatgpt(input)
      puts "ChatGPT says: #{response}"
    rescue => e
      puts "Error: #{e.message}"
    end
  end

  puts "Exiting Terminal Code Analyzer. Goodbye!"
end

analyze_terminal_code if __FILE__ == $0
