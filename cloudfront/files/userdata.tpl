#!/bin/bash -xe

# This is a just simple way of starting this demo app, this is not a cool way of doing this
# Exists plenty of other ways of doing this ;)
mkdir /opt/flask_app

wget ${bucket_and_key_object} -O /tmp/tmp_flask_app.zip

unzip /tmp/tmp_flask_app.zip /opt/flask_app/

cd /opt/flask_app

pip3 install -U flask

nohup python3 app.py > /tmp/output.log &
