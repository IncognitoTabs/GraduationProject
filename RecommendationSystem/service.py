import firebase_admin
from firebase_admin import db,credentials
import pandas as pd
import main as main
import random

class firebase_service():
    def __init__(self) :
        self.songs = []
        self.stats =[]
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred, {'databaseURL': 'https://fir-demo-29d5b-default-rtdb.firebaseio.com'})
        self.ref = db.reference('/')
        self.rs = main.recommender_system()
        
    def get_data_and_preprocessing(self):
        song_data = self.ref.child('songs').order_by_child('id').get()
        for key in song_data:
            self.songs.append(song_data[key])
        stat_data = self.ref.child('stats').order_by_child('songId').get()
        for key in stat_data:
            self.stats.append(stat_data[key])
        self.rs.data_preprocessing(songs=self.songs, stats= self.stats)  

    def get_trending_songs(self):
        top_trending = self.rs.get_popularity()
        return top_trending
        
    def get_user_similar_songs(self, userId):
        top_trending = self.rs.get_user_similarity(userId)
        return top_trending
    
    def get_item_similar_songs(self, songName):
        top_trending = self.rs.get_item_similarity(songName)
        return top_trending
    
    def random_update_stats(self):
        user_data = self.ref.child('users').get()
        user_id_list = []
        for key in user_data:
            user_id_list.append(user_data[key]['id'])
        song_data = self.ref.child('songs').get()
        song_id_list = []
        for key in song_data:
            song_id_list.append(song_data[key]['id'])
        stat_data = self.ref.child('stats').get()
        for key in stat_data:
            self.ref.child('stats/' + key).update(
                {
                    'userId': user_id_list[random.randint(0, len(user_id_list) - 1)],
                    'listenCount': random.randint(1, 30),
                    'songId':song_id_list[random.randint(0, len(song_id_list) - 1)]
                }
            )
        user_data = self.ref.child('stats').get()
        user_list = []
        for key in user_data:
            user_list.append(user_data[key])
        return pd.DataFrame(user_list).head()


