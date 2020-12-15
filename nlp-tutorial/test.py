import spacy
from pprint import pprint
from spacy import displacy
from collections import Counter

# note that this language model must be installed first, see docs
nlp = spacy.load("en_core_web_sm")

# read in text
text_file = 'data/text.txt'
with open(text_file, 'r') as f:
    text = f.read()

print(text)

# convert to named entities
doc=nlp(text)
pprint([(X.text, X.label_) for X in doc.ents])

