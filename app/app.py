import flask
import os

from flask import Flask

app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def home():
   return flask.render_template('filename.html')


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
