#!/usr/bin/python3

# sudo apt-get install python3-pip
# sudo pip3 install flask

import os
from flask import Flask, request, Response
from multiprocessing import Pool
#from parser import parse_sentence
import json

print "starting....";
app = Flask(__name__)
port = 80 if os.getuid() == 0 else 8000

pool = Pool(1, maxtasksperchild=50)
print " pool";
@app.route('/')
def index():
#  print [" index",parse_sentence];
  q = request.args.get("q", "")
  print [" index",q];
#  result = pool.apply(parse_sentence, [q])

  print [" index",result];

  return Response(
    response=json.dumps(result, indent=2),
    status=200,
    content_type="application/json")

# if __name__ == '__main__':
print [" main",port];
app.run(debug=True, port=port, host="0.0.0.0")

