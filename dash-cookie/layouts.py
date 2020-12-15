import dash_core_components as dcc
import dash_html_components as html
import dash_bootstrap_components as dbc

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


# define layout 
layout = html.Div([
    navbar,
    dbc.Container(
        [
            
        ]
    )
])
