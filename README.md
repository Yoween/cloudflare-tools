
# Cloudflare Dynamic DNS






## Installation

Download the source code or the release you want.  
The program is written in 2 languages: Bash and Python.  
They work the same it's up to you to chose which one you prefer.

#### Bash
```bash
chmod u+x cloudflare-dyndns.sh
./cloudflare-dyndns.sh
```

#### Python
```bash
python3 cloudflare-dyndns.py
```

## Configuration

Inside the file you chose, you'll find 4 variables with placeholder: 

- DOMAIN (`example.org`)
- EMAIL (`cloudflare.user@email.com`)
- API_KEY (`your-global-api-key`)
- API_TOKEN (`your-api-token`)

For the authentication, you have two choices :  
EMAIL + Global API Key -> Not recommended  
*OR*  
API Token -> Recommended

