# 📟 intellishell  
AI-powered terminal session logger and analyzer

![intellishell preview](https://github.com/ANG13T/intellishell/blob/main/assets/preview.gif)

## Features
- [x] Record terminal sessions
- [x] Analyze terminal sessions using GPT
- [x] Save terminal sessions to CSV
- [x] Search terminal sessions
- [x] View recorded terminal sessions

## Installation

#### 1. Clone the Repository
Clone the directory to your local machine:
```
git clone https://github.com/ANG13T/intellishell
cd intellishell
```

#### 2. Configuring YAML Variables
Open the `config.yaml` file and configure the following variables:
```yaml
openai_api_key: "your_openai_api_key"
log_dir: "path/to/log/directory"
session_catalog: "path/to/session_catalog.csv"
prompt: "You are a programmer and UNIX system and terminal master. You understand every command emmaculately and can articulate what terminal commands do at a high and concise level. Do not use any redundancy in how you speak. Be clear and straight to the point. You have a keen perception for ANSI escape codes."
```

You can generate an OpenAI API key by visiting the [OpenAI API](https://platform.openai.com/) page.

`log_dir` is the directory where the terminal sessions will be saved.

For `session_catalog`, you MUST generate a session_catalog.csv file. This file will be used to store the terminal sessions.

You can change the `prompt` variable to any prompt you want to use for the GPT model to analyze the session.

#### 3. Make the Script Executable:
```
chmod +x intellishell
```

#### 4. Configure the Path
Add the following to your `.bashrc` or `.zshrc` path file:
```sh
export PATH=$PATH:/path/to/intellishell
```

## Usage
Once you have the path configured, you can run the tool:
```
intellishell
```

## Contributing
intellishell is open to any contributions. Please fork the repository and make a pull request with the features or fixes you want to implement.

## Support
If you enjoyed IntelliShell, please consider [becoming a sponsor](https://github.com/sponsors/ANG13T) or donating on [buymeacoffee](https://www.buymeacoffee.com/angelinatsuboi) in order to fund my future projects.

To check out my other works, visit my [GitHub profile](https://github.com/ANG13T).

