#!/usr/bin/env python3
#
# Description:
#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

from flask import Flask, render_template, jsonify
import requests
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/earthquakes')
def get_earthquakes():
    base_url = "https://earthquake.usgs.gov/fdsnws/event/1/query"
    today = datetime.now().strftime('%Y-%m-%d')
    params = {
        'format': 'geojson',
        'starttime': '2024-10-11',  # 测历史50条，prod切today
        'limit': 100,
        'minmagnitude': 2.5
    }
    try:
        response = requests.get(base_url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        events = data['features'][:50]
        processed = []
        for event in events:
            props = event['properties']
            geom = event['geometry']['coordinates']
            processed.append({
                'time': props['time'],
                'title': props['title'],
                'mag': props['mag'],
                'lat': geom[1],
                'lon': geom[0],
                'depth': geom[2]
            })
        return jsonify({'earthquakes': processed})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
