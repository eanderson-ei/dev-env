import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State
import dash_bootstrap_components as dbc

# see https://community.plot.ly/t/nolayoutexception-on-deployment-of-multi-page-dash-app-example-code/12463/2?u=dcomfort
from app import server

from app import app
from layouts import layout  # import all layouts
import callbacks

# see https://dash.plot.ly/external-resources to alter header, footer and favicon
# add google analytics js in head tag if using
app.index_string = '''
<!DOCTYPE html>
<html>
    <head>
        {%metas%}
        <title>TITLE</title>
        {%favicon%}
        {%css%}
        <script src="https://rawgit.com/neo4j-contrib/neovis.js/master/dist/neovis.js"></script>
    </head>
    <body>
        <div></div>
        {%app_entry%}
        <footer>
            {%config%}
            {%scripts%}
            {%renderer%}
        </footer>
        <div></div>
    </body>
</html>
'''

# Layout placeholder
app.layout = html.Div([
    dcc.Location(id='url', refresh=False),
    html.Div(id='page-content')
])

@app.callback(Output('page-content', 'children'),
              [Input('url', 'pathname')])
def display_page(pathname):
    if pathname == '/':
        return layout
    # elif pathname == '/apps/app1':
    #      return layout1
    # elif pathname == '/apps/app2':
    #      return layout2
    else:
        return '404'


if __name__ == '__main__':
    app.run_server(debug=True)  # set to False before deploy
