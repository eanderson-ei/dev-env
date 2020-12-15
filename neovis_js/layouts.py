import dash_core_components as dcc
import dash_html_components as html
import dash_bootstrap_components as dbc
import visdcc

# import necessary functions from components/functions.py if needed

from app import app 

# Nav Bar
LOGO = app.get_asset_url('logo.png')  # update logo.png in assets/

# nav item links
nav_items = dbc.Container([
    # dbc.NavItem(dbc.NavLink('App 1', href='/app1')),
    # dbc.NavItem(dbc.NavLink('App 2', href='/app2'))
]
)

# navbar with logo
navbar = dbc.Navbar(
    dbc.Container(
        [
            html.A(
                # Use row and col to control vertical alignment of logo/brand
                dbc.Row(
                    [
                        dbc.Col(html.Img(src=LOGO, height="30px")),
                        dbc.Col(dbc.NavbarBrand("TITLE", className="ml-2")),
                    ],
                    align="center",
                    no_gutters=True,
                ),
                href="/",  # comment out to remove main page link
            ),
            dbc.NavbarToggler(id="navbar-toggler"),
            dbc.Collapse(
                dbc.Nav(
                    [nav_items], className="ml-auto", navbar=True
                ),
                id="navbar-collapse",
                navbar=True
            ),
        ]
    ),
    color="dark",
    dark=True,
    className="mb-5"
)

# define layout items
with open('html/index.html', 'r') as f:
    text = f.read()

html_inject = html.Iframe(
    src=text
)

# define layout 
layout = html.Div([
    navbar,
    dbc.Container(
        [
           visdcc.Run_js(id='html_inject'),
           html.Button("Push me", id='run'),
           html.Div(id='viz', 
                    children=[],
                    style={
                'width': '900px',
                'height': '700px',
                'border': '1px solid lightgray',
                'font': '22pt arial',
            })
        ]
    )
])


# https://community.plotly.com/t/share-visdcc-a-dash-core-components-for-vis-js-network/5417/6

