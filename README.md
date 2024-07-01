### IntelliShell
AI-powered terminal session logger and analyzer

### Preview

### Features
- [x] Record terminal sessions
- [x] Analyze terminal sessions using GPT
- [x] Save terminal sessions to CSV
- [x] Search terminal sessions

### Installation
Clone the directory to your local machine:
```
git clone https://github.com/ANG13T/IntelliShell
cd IntelliShell
```

### Configuring YAML Variables
Open the `config.yaml` file and configure the following variables:
```yaml
openai_api_key: "your_openai_api_key"
log_dir: "path/to/log/directory"
session_catalog: "path/to/session_catalog.csv"
prompt: "You are a programmer and UNIX system and terminal master. You understand every command emmaculately and can articulate what terminal commands do at a high and concise level. Do not use any redundancy in how you speak. Be clear and straight to the point. You have a keen perception for ANSI escape codes."
```

Grant permissions to the script file:
```
chmod +x intellishell.sh
```

## Configure Path
For BASH users, add the following to your `.bashrc` or `.zshrc` file:
```sh
export PATH=$PATH:/path/to/IntelliShell
```

### Usage
Once you have the path configured, you can run the tool:
```
intellishell
```

### Contributing 

