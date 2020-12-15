from dash.dependencies import Input, Output, State
from dash.exceptions import PreventUpdate
import dash_bootstrap_components as dbc

# import necessary functions from components/functions.py if needed

from app import app


# Nav bar 
@app.callback(
    Output("navbar-collapse", "is_open"),
    [Input("navbar-toggler", "n_clicks")],
    [State("navbar-collapse", "is_open")],
)
def toggle_navbar_collapse(n, is_open):
    if n:
        return not is_open
    return is_open


# @app.callback(
#     Output('html_inject', 'run'),
#     [Input('run', 'n_clicks')]
# )
# def inject_html(n_clicks):
#     if n_clicks:
#         js = """
#             draw()
#             """
#         return js

@app.callback(
    Output('net', 'data'),
    [Input('label', 'value')])
def myfun(x):
    data ={'nodes':[{'id': 1, 'label':    x    , 'color':'#00ffff'},
                    {'id': 2, 'label': 'Node 2'},
                    {'id': 4, 'label': 'Node 4'},
                    {'id': 5, 'label': 'Node 5'},
                    {'id': 6, 'label': 'Node 6'}                    ],
           'edges':[{'id':'1-3', 'from': 1, 'to': 3},
                    {'id':'1-2', 'from': 1, 'to': 2} ]
           }
    return data

@app.callback(
    Output('net', 'options'),
    [Input('color', 'value')])
def myfun(x):
    return {'nodes':{'color': x}}

app.clientside_callback(
    """
    draw()
    """,
    Output('viz', 'children'),
    [Input('run', 'n_clicks')]
)
