import glob
import pandas as pd
import nltk
import re
import numpy as np

from nltk.corpus import stopwords
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans, DBSCAN
from sklearn.decomposition import PCA

def load_data():
    return map(lambda x: Path(x).read_text(), glob.glob(r'./output/*.txt'))

# copied from https://medium.com/mlearning-ai/text-clustering-with-tf-idf-in-python-c94cd26a31e7
def preprocess_text(text: str, remove_stopwords: bool) -> str:
    """This utility function sanitizes a string by:
    - removing links
    - removing special characters
    - removing numbers
    - removing stopwords
    - transforming in lowercase
    - removing excessive whitespaces
    Args:
        text (str): the input text you want to clean
        remove_stopwords (bool): whether or not to remove stopwords
    Returns:
        str: the cleaned text
    """

    # remove links
    text = re.sub(r"http\S+", "", text)
    # remove special chars and numbers
    text = re.sub("[^A-Za-z]+", " ", text)
    # remove stopwords
    if remove_stopwords:
        # 1. tokenize
        tokens = nltk.word_tokenize(text)
        # 2. check if stopword
        tokens = [w for w in tokens if not w.lower() in stopwords.words("english")]
        tokens = [w for w in tokens if not w.lower() in stopwords.words("french")]
        tokens = [w for w in tokens if not w.lower() in stopwords.words("german")]
        # 3. join back together
        text = " ".join(tokens)
    # return text in lower case and stripped of whitespaces
    text = text.lower().strip()
    return text


#nltk.download('punkt')
#nltk.download('stopwords')

df = pd.DataFrame(load_data(), columns=["corpus"])

# todo: remove strings until first .

df['cleaned'] = df['corpus'].apply(lambda x: preprocess_text(x, remove_stopwords=True))

# vectorize stuff
vectorizer = TfidfVectorizer(sublinear_tf=True, min_df=5, max_df=0.95)
X = vectorizer.fit_transform(df['cleaned'])

# and now do kmeans or dbscan
kmeans = DBSCAN()
kmeans.fit(X)
clusters = kmeans.labels_

print(str(df))

def get_top_keywords(X, clusters, n_terms):
    """This function returns the keywords for each centroid of the KMeans"""
    df = pd.DataFrame(X.todense()).groupby(clusters).mean() # groups the TF-IDF vector by cluster
    terms = vectorizer.get_feature_names_out() # access tf-idf terms
    for i,r in df.iterrows():
        print('\nCluster {}'.format(i))
        print(','.join([terms[t] for t in np.argsort(r)[-n_terms:]])) # for each row of the dataframe, find the n terms that have the highest tf idf score
            
print(str(get_top_keywords(X, clusters, 10)))
