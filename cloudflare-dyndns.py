import requests
import json
from datetime import datetime

DOMAIN = "example.org"
EMAIL = "cloudflare.user@email.com"
API_KEY = "your-global-api-key"

API_TOKEN = "your-api-token"  # replace with your actual API token

# Choose authentication method: 'global_key' or 'token'
auth_method = 'token'  # change to 'global_key' to use global API key

headers = {
    'Content-Type': 'application/json'
}

if auth_method == 'global_key':
    headers['X-Auth-Email'] = EMAIL
    headers['X-Auth-Key'] = API_KEY
elif auth_method == 'token':
    headers['Authorization'] = f'Bearer {API_TOKEN}'

def get_new_ip():
    return requests.get('https://icanhazip.com').text.strip()

def get_zone_id():
    response = requests.get(f'https://api.cloudflare.com/client/v4/zones?name={DOMAIN}&status=active&page=1&per_page=20&order=status&direction=desc&match=all', headers=headers)
    return json.loads(response.text)['result'][0]['id']

def get_dns_records():
    response = requests.get(f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?type=A&page=1&per_page=20&order=type&direction=desc&match=all', headers=headers)
    data = json.loads(response.text)
    return [record['name'] for record in data['result']]

def update_dns(domain_name):
    response = requests.get(f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records?type=A&name={domain_name}&page=1&per_page=20&order=type&direction=desc&match=all', headers=headers)
    data = json.loads(response.text)
    dns_id = data['result'][0]['id']
    old_ip = data['result'][0]['content']
    dt = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if new_ip != old_ip:
        print(f"Old IP: {old_ip}")
        print(f"New IP: {new_ip}")

        payload = {
            "type": "A",
            "name": domain_name,
            "content": new_ip,
            "proxied": True
        }

        response = requests.put(f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{dns_id}', headers=headers, data=json.dumps(payload))
        success = json.loads(response.text)['success']
        print(f"{dt}: Successfully updated {domain_name}: {success}")
    else:
        print(f"Same IP for {domain_name}: {new_ip}")

new_ip = get_new_ip()
zone_id = get_zone_id()

dns_records = get_dns_records()

for record in dns_records:
    update_dns(record)