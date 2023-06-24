import pandas as pd
import recommenders as Recommenders
from nltk.stem.porter import PorterStemmer

class recommender_system():
    def __init__(self) :
        self.songs_df = None
        self.songs_copy_df = None
        self.stats_df = None
        self.song_stat_df = None
        self.ps=PorterStemmer()

    def data_preprocessing(self, songs, stats):
        self.songs_df = pd.DataFrame(songs).rename(columns={'id' : 'songId'}).dropna().drop_duplicates(['songId', 'title'])
        self.stats_df = pd.DataFrame(stats)
        self.song_stat_df = pd.merge(self.stats_df, self.songs_df, on='songId', how='left')
        self.song_stat_df.drop(columns=['320kbps','album_id' ,'duration','has_lyrics' , 'image','perma_url', 'url', 'release_date', 'genre'],inplace=True)
        # to convert string into list of strings 
        self.song_stat_df['title'] = self.song_stat_df['title'].apply(self.spliting)
        self.song_stat_df['artist'] = self.song_stat_df['artist'].apply(self.spliting)
        self.song_stat_df['album'] = self.song_stat_df['album'].apply(self.spliting)
        self.song_stat_df['subtitle'] = self.song_stat_df['subtitle'].apply(self.spliting)
        self.song_stat_df['year'] = self.song_stat_df['year'].apply(self.spliting)

        self.song_stat_df['all_tags'] = self.song_stat_df['title'] + self.song_stat_df['artist'] + self.song_stat_df['album'] + self.song_stat_df['subtitle']+ self.song_stat_df['year']
        self.song_stat_df.drop(columns=['title','artist' ,'album','language' , 'subtitle','year'],inplace=True)

        self.song_stat_df['all_tags']=self.song_stat_df['all_tags'].apply(self.convert_lower)
        self.song_stat_df['all_tags'] = self.song_stat_df['all_tags'].apply(self.steming)
        self.song_stat_df['all_tags'] = self.song_stat_df['all_tags'].apply(lambda x: " ".join(x))

    def spliting(self, text):
        text=str(text).split()
        return text
    
    def convert_lower(self, text):
        l=[]
        for item in text:
            l.append(item.lower())
        return l
    
    def steming(self, text):
        l=[]
        for i in text:
            l.append(self.ps.stem(i))
        return l
    
    def get_popularity(self):
        pr = Recommenders.popularity_recommender_py()
        pr.create(self.song_stat_df, 'songId')
        popular_songIds = pr.recommend()
        return self.get_song_info_by_list_id(popular_songIds)
    
    def get_item_similarity(self, song_id):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_stat_df, 'userId', 'songId')
        item_similar_songIds = ir.get_similar_items(song_id)
        return self.get_song_info_by_list_id(item_similar_songIds)
    
    def get_user_similarity(self, user_id):
        ir = Recommenders.item_similarity_recommender_py()
        ir.create(self.song_stat_df, 'userId', 'songId')
        user_similar_songIds = ir.recommend(user_id)
        return self.get_song_info_by_list_id(user_similar_songIds)
    
    def get_song_info_by_list_id(self, list_id):
        columns = ['320kbps','album','album_id','artist','duration','genre','has_lyrics','songId','image','language','perma_url','release_date','subtitle','title','url','year']
        list_result = pd.DataFrame(columns= columns)
        list_result_json = []
        for id in list_id:
            result = self.songs_df.query('songId == @id')
            list_result = pd.concat([list_result, result], ignore_index=True).drop_duplicates(['songId'])
        list_result = list_result.rename(columns={ 'songId': 'id'})
        for i in range(0,len(list_result)):
            list_result_json.append(list_result.iloc[i].to_dict())
        return list_result_json

