import requests


class MyRequestClass:
    def fetch_json(self, url):
        response = requests.get(url)
        return response.json()
