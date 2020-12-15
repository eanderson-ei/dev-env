import dash
import dash_bootstrap_components as dbc
import dash_auth
import json
import os

external_stylesheets = [dbc.themes.FLATLY]  # Also try LITERA, SPACELAB
external_scripts = ["https://rawgit.com/neo4j-contrib/neovis.js/master/dist/neovis.js"]

app = dash.Dash(__name__, 
                external_stylesheets=external_stylesheets,
                external_scripts=external_scripts,
                show_undo_redo=False,)
server = app.server
app.config.suppress_callback_exceptions = True

# UNCOMMENT FOR BASIC AUTHENTICATION
# # Keep this out of source code repository - save in a file or a database
# # Local dev
# try:
#     with open('secrets/passwords.json') as f:
#         VALID_USERNAME_PASSWORD_PAIRS = json.load(f)
# # Heroku dev
# except:
#     json_creds = os.environ.get("VALID_USERNAME_PASSWORD_PAIRS")
#     VALID_USERNAME_PASSWORD_PAIRS = json.loads(json_creds)

# auth = dash_auth.BasicAuth(
#     app,
#     VALID_USERNAME_PASSWORD_PAIRS
# )
