import dash
from dash.dependencies import ClientsideFunction, Input, Output, State
import dash_core_components as dcc
import dash_html_components as html

external_scripts = ["https://rawgit.com/neo4j-contrib/neovis.js/master/dist/neovis.js"]

app = dash.Dash(__name__,
                external_scripts=external_scripts)


app.layout = html.Div(children=
    [
        dcc.Input(id='input', value='Regional Climate Change Program (RCCP)'),
        html.Div(id='viz', 
                    children=[],
                    style={
                'width': '900px',
                'height': '700px',
                'border': '1px solid lightgray',
                'font': '12pt arial',
            })
    ]
)

app.clientside_callback(
    output=Output('viz', 'children'),
    inputs=[Input('input', 'value')],
    clientside_function = ClientsideFunction(
        namespace='clientside',
        function_name ='draw'
    )
)


if __name__ == '__main__':
    app.run_server(debug=True)