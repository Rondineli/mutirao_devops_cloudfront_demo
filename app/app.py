import flask
import os

from flask import Flask

app = Flask(__name__)

@app.route('/healthz', methods=['GET', 'HEAD'])
def healthz():
    return 'This is working!'

@app.route('/', methods=['GET', 'POST'])
def home():
   return flask.render_template('filename.html')

@app.route('/by-header', methods=['GET'])
def test_by_header():
    return 'Hello!'

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True)
