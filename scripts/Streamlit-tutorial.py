import streamlit as st
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

"""
# Utilization Report
"""
# TODO
# This will break for anyone with a 0% utilization in a month (like CH), update 
# how Predicted Hours column in utilization is updated
# Plotting still has manual white lines for the prediction space.
# No FTE support yet

hours_report_path = ''
input_data_path = ''

@st.cache
def load_interim():
    df = pd.read_excel('../data/utilization-tracker/restpoint_ea.xlsx')
    return df
    
# @st.cache
def load_hours_report(hours_report_path):
    df = pd.read_excel(hours_report_path, parse_dates=['Entry Data'])
    df['Entry Month'] = pd.DatetimeIndex(df['Entry Data']).strftime('%b')
    df['Hours Worked'] = df['Hours Worked'] + df['Time Off Hrs']
    df['Activity Name'] = df['Activity Name'] + df['Time Off Type']
    df.drop(['Time Off Hrs', 'Time Off Type'], axis=1, inplace=True)
    # Activity names are imported with trailing whitespace, use pd.str.strip to remove
    df['Activity Name'] = df['Activity Name'].str.strip()
    
    return df


# @st.cache
def load_activities(input_data_path):
    activities = pd.read_excel(input_data_path, 'ACTIVITY')
    
    return activities


# @st.cache
def load_date_info(input_data_path):
    dates = pd.read_excel(input_data_path, 'DATES', parse_dates=['Date'])
    dates['Month'] = pd.DatetimeIndex(dates['Date']).strftime('%b')
    months = dates.groupby('Month').max()
    months['FTE'] = months['Remaining'] * 8
    
    return dates, months


# @st.cache
def load_employees(input_data_path):
    employees = pd.read_excel(input_data_path, 'NAMES')
    names = employees['NAMES'].unique()
    
    return names


def build_utilization(name, hours_report, activities, dates, months):
    # Subset and copy (don't mutate cached data, per doc)
    df = hours_report.loc[hours_report['User Name']==name].copy()

    # Join activities
    df = df.set_index('Activity Name').join(
        activities.set_index('Activity Name')
        ).reset_index()

    # Calculate monthly total hours
    individual_hours = (df[df['User Name']==name]
                        .groupby(['Entry Month', 'Classification']).sum()
                        .reset_index()
                        .set_index('Entry Month'))
    
    # Save only billable hours
    utilization = individual_hours.loc[individual_hours['Classification']=='Billable']
    
    # Zero fill billable for remaining months (IMPROVE)
    list_months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
                   'Jan', 'Feb', 'Mar']
    # list_months = months.index
    existing_months = utilization.index
    columns = utilization.reset_index().columns
    utilization.reset_index(inplace=True)
    for m in list_months:    
        if m not in existing_months:
            new_row = pd.Series([m, "Billable", 0], columns)
            utilization = utilization.append(new_row, ignore_index=True)
    
    utilization.set_index('Entry Month', inplace=True)
    
    # Update billable with FTE per month
    utilization = utilization.join(months['FTE'])
    
    # Calculate actual utilization
    utilization['Utilization'] = utilization['Hours Worked'] / utilization['FTE']
    
    # Calculate predicted utilization for this month
    # Copy Utilization to new column, Util to Date
    utilization['Util to Date'] = utilization['Utilization']
    
    # Calculate predicted utilization based on billable hours this month
    this_month = individual_hours.last_valid_index()
    last_day_worked = df['Entry Date'].max()
    days_remaining = dates.loc[dates['Date']==last_day_worked, 'Remaining']
    current_hours = utilization.loc[this_month, 'Hours Worked']
    current_utilization = utilization.loc[this_month, 'Utilization']
    hours_remaining = days_remaining * 8    
    predicted_hours = current_hours + (hours_remaining * current_utilization)
    predicted_utilization = predicted_hours/utilization.loc[this_month, 'FTE']
    
    # Update Util to Date column at the current month with predicted
    utilization.at[this_month, 'Util to Date'] = predicted_utilization
    
    # Forecast forward looking utilization
    # Calculate predicted utilization based on utilization to date
    utilization['Predicted Hours'] = utilization['Util to Date'] * utilization['FTE']
    
    # Extract number of hours expected based on utilization to date
    predicted_value = utilization.loc[this_month, 'Predicted Hours']
    
    # Populate future months with predicted_value  #UPDATE
    utilization.loc[utilization['Utilization'] == 0, 'Predicted Hours'] = predicted_value
    
    # Calculate cumulative utilization as Expected Utilization
    utilization['Expected Utilization'] = (utilization['Predicted Hours'].cumsum() 
                                           / utilization['FTE'].cumsum())
    
    return utilization


def plot_hours(data, target, current_month=12):
    plt.rcParams['font.sans-serif'] = 'Tahoma'
    plt.rcParams['font.family'] = 'sans-serif'
    plt.rcParams['font.size'] = 13

    util_color = '#006040'
    util_target = target

    current_month_index = current_month - 4  # Month of april is 4

    fig, ax1 = plt.subplots(figsize=[10.75,7])

    # Hide grid lines to denote prediction portion of graph, Note zorder must be specified
    # in fill_between call
    for i in [9, 10, 11]:
        ax1.axes.axvline(i, color='white', linewidth=2)

    # Plot data
    ax1.plot(data['Expected Utilization']*100, color=util_color, linewidth=3, alpha=.85)

    # Plot actuals
    ax1.plot(data['Util']*100, color=util_color, marker='x', lw=0)

    # Plot projected
    ax1.plot(data['Util to Date']*100, color=util_color, marker='o', lw=0, alpha=1)

    # Plot targets
    ax1.plot([util_target]*12, color=util_color, linestyle='dotted')
    
    # Label actuals
    for x, y in zip(np.arange(0,12), data['Util']*100):
        label = f'{y:.0f}%'
        if y > 0:
            ax1.annotate(label, 
                        (x, y), 
                        textcoords="offset points", 
                        xytext=(10,0), 
                        ha='left',
                        va='center',
                        color = 'dimgrey')

    # Set title
    ax1.set_title('Are you on track to meet your utilization target?', 
                  loc='right', 
                  fontsize=15)

    # Adjust axes ranges
    ax1.set_ylim(0, 120)

    # Adjust number of labels
    ax1.yaxis.set_major_locator(plt.MaxNLocator(6))

    # Format y labels as percent
    ax1.yaxis.set_major_formatter(plt.FuncFormatter('{:.0f}%'.format))

    # Set x labels
    ax1.set_xticks(np.arange(0,12))
    ax1.set_xticklabels(data['Entry Month'])

    # Add grid Lines
    ax1.yaxis.grid(False)
    ax1.xaxis.grid(True)

    # Customize grid lines
    ax1.axes.grid(axis='x', linestyle='-')

    # Set below graph objects
    ax1.set_axisbelow(True)

    # Remove Axes ticks
    ax1.tick_params(axis='both', which='both', 
                    bottom=False, top=False, left=False, right=False)

    # Recolor axis labels
    ax1.tick_params(colors='dimgrey')

    # Remove axes spines
    ax1.spines['top'].set_visible(False)
    ax1.spines['left'].set_visible(False)
    ax1.spines['right'].set_visible(False)
    ax1.spines['bottom'].set_visible(True)
    ax1.spines['bottom'].set_color('silver')

    # Labels
    util_value = (data.loc[data['Entry Month']=='Mar', 'Expected Utilization']
                  * 100)
    ax1.text(11.1, util_value-3, f' Predicted \n Utilization ({int(util_value)}%)', 
             color=util_color)

    # Indicate current month
    ax1.get_xticklabels()[current_month_index].set_fontweight('bold')
    ax1.get_xticklabels()[current_month_index].set_color(util_color)
    
    return fig, util_value.item()

def message(predicted, target):
    if predicted > target and target > 0:
        st.success("You're on track to meet your utilization!")
    elif predicted < target and target > 0: 
        diff = round(target - predicted, 0)
        st.warning(f"You're on track to miss your target by {diff}%")

def balloons(predicted, target):
    if predicted > target and target > 0:
        st.balloons()
        
# Load data
# hours_report = load_hours_report(hours_report_path)
# activities = load_activities(input_data_path)
# dates, months = load_date_info(input_data_path)
# names = load_employees(input_data_path)

# User selects name
names = ['Erik Anderson', 'Not Erik Anderson']
name = st.selectbox(
    'Who are you?', 
    (names)
)

# User inputs target utilization
target_util = st.number_input("What's your target utilization?", 0, 100)

# Build utilization report for user
df = load_interim()
# df = build_utilization(hours_report, activities, dates, months)

# Plot results
plot, predicted_utilization = plot_hours(df, target_util)
st.pyplot(plot)

# Display a congratulatory or warning message based on prediction 
message(predicted_utilization, target_util)

# User may display data
if st.checkbox('Show data'):
    st.subheader('Utilization Data')
    st.table(df)

# ...And balloons, just cause
if not st.checkbox("That's enough balloons"):
    balloons(predicted_utilization, target_util)
    