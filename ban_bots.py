import requests
import time
import os

DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1434262975430135930/xJw47cQdMO1w-QlQOdT6VvhCaDuT7_2eBbUkUP4ZNZ_q67ddGdNalz4Sc3ZGNoIUs3Wj"

def send_to_discord(message):
    try:
        data = {"content": message}
        response = requests.post(DISCORD_WEBHOOK, json=data, timeout=5)
        return response.status_code == 200
    except:
        return False

def monitor_ban_log():
    last_size = 0
    log_file = "data/ban_logs.txt"
    
    while True:
        try:
            if os.path.exists(log_file):
                current_size = os.path.getsize(log_file)
                if current_size > last_size:
                    with open(log_file, "r") as f:
                        lines = f.readlines()
                        new_lines = lines[last_size:]
                        for line in new_lines:
                            if "БАН |" in line:
                                send_to_discord("🚫 " + line.strip())
                    last_size = current_size
        except Exception as e:
            print(f"Error: {e}")
        
        time.sleep(5)

if __name__ == "__main__":
    monitor_ban_log()
