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
        popular_songIds = pr.recommend()
        return self.get_song_info_by_list_id(popular_songIds).drop_duplicates(['songId'])
    
    def get_item_similarity(self, song_id):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_df, 'userId', 'songId')
        item_similar_songIds = ir.get_similar_items(song_id)
        return self.get_song_info_by_list_id(item_similar_songIds).drop_duplicates(['songId'])
    
    def get_user_similarity(self, user_id):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_df, 'userId', 'songId')
        user_similar_songIds = ir.recommend(user_id)
        return self.get_song_info_by_list_id(user_similar_songIds).drop_duplicates(['songId'])
    
    def get_song_info_by_list_id(self, list_id):
        columns = ['320kbps','album','album_id','artist','duration','genre','has_lyrics','songId','image','language','perma_url','release_date','subtitle','title','url','year']
        list_result = pd.DataFrame(columns= columns)
        for id in list_id:
            result = self.songs.query('songId == @id')
            list_result = pd.concat([list_result, result], ignore_index=True)
        return list_result
        

