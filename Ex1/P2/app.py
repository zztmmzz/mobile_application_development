from flask import Flask, request, jsonify
from math import *

app = Flask(__name__)

R = 6371

@app.route('/distance', methods=['POST'])
def calculate1():
    data = request.get_json()
    point_1 = data['point_1']
    lat_1 = float(point_1['lat'])
    lng_1 = float(point_1['lng'])

    point_2 = data['point_2']
    lat_2 = float(point_2['lat'])
    lng_2 = float(point_2['lng'])

    phi_1 = lat_1 * pi / 180
    phi_2 = lat_2 * pi / 180

    delta_phi = (lat_2 - lat_1) * pi / 180
    delta_lamda = (lng_2 - lng_1) * pi / 180

    a = sin(delta_phi / 2) * sin(delta_phi / 2) + cos(phi_1) * cos(phi_2) * sin(delta_lamda / 2) * sin(delta_lamda / 2)
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    d = R * c

    test = jsonify({"result": d})
    return test
# if __name__ == '__main__':
#     app.run()