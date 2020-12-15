"""This script reads a pdf into a text file for later use"""

"""PyPDF2 does not work with the Mac PDF writer"""
# import PyPDF2

# pdf_file_object = open('data/raw/story1.pdf')

# pdf_reader = PyPDF2.PdfFileReader(pdf_file_object)

# print(pdf_reader.numPages)

# text = []
# for page in pdf_reader.pages:
#     text.append(page.extractText())

# # creating a page object 
# pageObj = pdf_reader.getPage(0) 
  
# # extracting text from page 
# print(pageObj.extractText()) 

from tika import parser

raw = parser.from_file('data/raw/story2.pdf')
text = raw['content']
text = text.replace('\n', '')

fname = 'data/processed/text2.txt'
with open(fname, 'w', encoding='utf-8') as f:  # can encoding be read from pdf?
    f.write(text)