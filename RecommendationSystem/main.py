import pandas as pd
import numpy as np
import recommenders as Recommenders

class recommender_system():
    def __init__(self) :
        self.songs = None
        self.stats = None
        self.song_df = None

    def data_preprocessing(self, songs, stats):
        self.songs = pd.DataFrame(songs).rename(columns={'id' : 'songId'})
        self.stats = pd.DataFrame(stats)
        self.song_df = pd.merge(self.stats, self.songs.drop_duplicates(['songId']), on='songId', how='left')
        self.song_df['song'] = self.song_df['title']+' - '+self.song_df['artist']
    
    def get_popularity(self):
        pr = Recommenders.popularity_recommender_py()
        pr.create(self.song_df, 'songId')
        return pr.recommend()
    
    def get_item_similarity(self, keywork):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_df, 'userId', 'song')
        return ir.get_similar_items(keywork)
    
    def get_user_similarity(self, user_id):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_df, 'userId', 'song')
        return ir.recommend(user_id)
        

