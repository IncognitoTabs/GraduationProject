from flask import Flask, request, jsonify
from gevent.pywsgi import WSGIServer
import service as sv


app = Flask(__name__)
self_sv = sv.firebase_service()
self_sv.get_data_and_preprocessing()

@app.get('/get-trending-songs')
def get_trending_songs():
    return jsonify(self_sv.get_trending_songs())

@app.get('/get_user_similar_songs/<user_id>')
def get_user_similar_songs(user_id):
    return jsonify(self_sv.get_user_similar_songs(user_id))

@app.get('/get_item_similar_songs/<songId>')
def get_item_similar_songs(songId):
    return jsonify(self_sv.get_item_similar_songs(songId))

if __name__ == "__main__":
    http_server = WSGIServer(('', 5000), app)
    http_server.serve_forever()