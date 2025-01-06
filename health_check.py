import requests

def health_check():
    url = "http://localhost:5001/health"
    response = requests.get(url)
    if response.status_code != 200:
        response_json = response.json()
        services = response_json["services"]
        return f"Database: {services["database"]}\nRedis: {services["redis"]}"
    return "All services are running"

if __name__ == "__main__":
    print(health_check())