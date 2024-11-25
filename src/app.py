import os
from flask import Flask
from datetime import datetime, timezone

DEFAULT_PORT = 8080
PORT = os.environ.get('GMS_APP_PORT', DEFAULT_PORT)

app = Flask(__name__)


@app.route("/health")
def health():
    return '<p>I am alive!</p>'


@app.route("/")
def hello_world():
    time = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
    return '<p>Hello! World! You opened the page at {time} UTC</p>'.format(time=time)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
