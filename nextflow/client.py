import os
from flask import Flask, request, Response, redirect, jsonify, send_file, send_from_directory, safe_join, abort, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import requests
import time
import zipfile




app =Flask(__name__)
# Run server
if __name__ == '__main__':
    #debug is true for dev mode
    app.run(debug=True)
    


@app.route(f"/workflow/run", methods=['POST'])
def run_workflow():
	'''
	'''
	payload={}
	data = json.loads(request.get_data())
	return json.dumps(payload)

@app.route(f"/workflow/logs", method=['GET'])
def get_logs():
    '''
    '''
    payload={}
	return json.dumps(payload)

@app.route(f"/workflow/results", method=['GET'])
	'''
	'''
	payload={}
	return json.dumps(payload)


@app.route(f"/workflow/status", method=['GET'])
def get_workflow_status():
	'''
	'''
	payload={}
	return json.dumps(payload)

@app.route(f"/workflows/delete", method=['DELETE'])
def delete_workflow():
	'''
	'''
	payload={}
	return json.dumps(payload)




