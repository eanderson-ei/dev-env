"""
Named Entity Recognition utilizes a machine learning model to extract entities
like 'PERSON' and 'CITY' from text. It's a good first pass on text to identify
important attributes. Follow with matching (see matching.py).
"""
from bs4 import BeautifulSoup
import requests
import re
import spacy
from spacy import displacy
from pprint import pprint

# def url_to_string(url):
#     res = requests.get(url)
#     html = res.text
#     soup = BeautifulSoup(html, "html5lib")
#     for script in soup(["script", "style", 'aside']):
#         script.extract()
#     return " ".join(re.split(r'[\n\t]+', soup.get_text()))

# ny_bb = url_to_string('https://www.nytimes.com/2018/08/13/us/politics/peter-strzok-fired-fbi.html?hp&action=click&pgtype=Homepage&clickSource=story-heading&module=first-column-region&region=top-news&WT.nav=top-news')

nlp = spacy.load("en_core_web_sm")

# article = nlp(ny_bb)

with open('text.txt', 'r', encoding='utf-8') as f:
    text = f.read()
    
article = nlp(text)

sentences = [x for x in article.sents]

displacy.serve(article, style = 'ent')
