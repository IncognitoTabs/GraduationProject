from flask import Flask, request, jsonify
from gevent.pywsgi import WSGIServer
import service as sv


app = Flask(__name__)
self_sv = sv.firebase_service()
self_sv.get_data_and_preprocessing()

@app.get('/get_random_artist')
def get_random_artist():
    return jsonify(self_sv.get_random_artist())

@app.get('/get-trending-songs')
def get_trending_songs():
    return jsonify(self_sv.get_trending_songs())

@app.get('/get_user_similar_songs/<user_id>')
def get_user_similar_songs(user_id):
    return jsonify(self_sv.get_user_similar_songs(user_id))

@app.get('/get_item_similar_songs/<songId>')
def get_item_similar_songs(songId):
    return jsonify(self_sv.get_item_similar_songs(songId))

@app.post('/get_recommend_by_hobbies')
def get_recommend_by_hobbies():
    data = request.get_json()
    return jsonify(self_sv.get_item_similar_songs_by_keywork(data['keywork']))

if __name__ == "__main__":
    http_server = WSGIServer(('', 5000), app)
    http_server.serve_forever()