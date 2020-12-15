"""
Rule-based matching is an alternative to training a new Named Entity 
Recognition model. Use regex-like pattern matching to add entities to 
the NER output.
"""
import spacy
from spacy.matcher import Matcher
from spacy import displacy
from spacy.tokens import Span
from pprint import pprint

nlp = spacy.load("en_core_web_sm")

with open('data/processed/text2.txt', 'r', encoding = 'utf-8') as f:
    text = f.read()
    
article = nlp(text)

matcher = Matcher(nlp.vocab)

pattern = [{'LOWER': 'climate'}, {'LOWER': 'change'}]
matcher.add("climate", None, pattern)

matches = matcher(article)

for match_id, start, end in matches:
    try:
        span = Span(article, start, end, label=match_id)
        article.ents = list(article.ents) + [span]  # add span to doc.ents
    except:
        pass  # can't overwrite existing entities

pprint([(ent.text, ent.label_) for ent in article.ents])

html = displacy.render(article, style="ent")

with open('entity-highlight.html', 'w+', encoding='utf-8') as f:
    f.write(html)

displacy.serve(article, style="ent")