import matplotlib.pyplot as plt
import streamlit as st
import pandas as pd

"""
# Utilization Report
How's my utilization?
"""

project_class_table = pd.read_csv('../project-classification.csv')

df = pd.read_csv('../Billable Hours Report 2019-12-09.csv')

# df.groupby(['User Name', 'Activity Name']).sum()

df.head()

