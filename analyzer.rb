require 'httparty'
require 'json'

OPENAI_API_ENDPOINT = 'https://api.openai.com/v1/engines/davinci-codex/completions'

# Loads API Key from YAML config file
def load_api_key()
    config = YAML.load_file('config.yaml')
    config['openai_api_key']
end

# Function to interact with ChatGPT
def ask_chatgpt(prompt)
  api_key = load_api_key()
  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  body = {
    prompt: prompt,
    max_tokens: 150
  }.to_json

  response = HTTParty.post(OPENAI_API_ENDPOINT, headers: headers, body: body)

  if response.code == 200
    return JSON.parse(response.body)['choices'][0]['text'].strip
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

    # Send input to ChatGPT
    response = ask_chatgpt(input)

    puts "ChatGPT says: #{response}"
  end

  puts "Exiting Terminal Code Analyzer. Goodbye!"
end


analyze_terminal_code if __FILE__ == $0