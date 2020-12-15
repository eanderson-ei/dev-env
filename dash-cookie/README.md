# README

This library ...

To run: `python index.py`.

## Contents

**app.py**: barebones Dash app with authentication

**index.py**: 'home' page of the app that handles page navigation

**layouts.py**: includes all layouts and bootstrap components

**callbacks.py**: includes all callbacks except for a few in index.py to handle the page navigation

**assets/**

* this folder is automatically detected by Dash (as named) and includes a favicon and logo image files

**components/**

* **\_\_init\_\_.py**: allows importing from components

## Design

### Inputs

- 

### Flow

1. 

### Outputs

- 

## Next Steps

- [ ] 

## TODO

- [ ] 

## Tips

### Starting a Dash project

How to start a Dash project

```bash
conda create -n <ENV_NAME> python
conda activate <ENV_NAME>
pip install dash==1.11.0  # use most recent version from Users Guide
pip install dash-auth==1.3.2  # for basic login protection
pip install requests  # this is not included in the docs, not sure why it isn't installed as a dependency, but it is needed
pip install dash-bootstrap-components  # if using Bootstrap
```
### Authentication
For authentication, save a `.json` file in `secrets/` with the following code (INCLUDE THIS FILE IN YOUR GITIGNORE. Note I also include a .keep file in there so people who clone the repo know where that should be.) You can include as many username, password pairs as you want, separated by a colon (double quotes required).

```json
{
    "username": "password"
}
```

When deploying to Heroku, go to the Config Vars option under 'Settings' and paste the content of the json file there. The `KEY` will be `VALID_USERNAME_PASSWORD_PAIRS` and the `VALUE` will be the contents of the json file.

When deploying to Heroku, go to the Config Vars option under 'Settings' and paste the content of the json file there. The `KEY` will be `VALID_USERNAME_PASSWORD_PAIRS` and the `VALUE` will be the contents of the json file.

### Assets

Store a logo, favicon, and custom css or javascript in a folder `./assets/` and they will automatically be discovered by Dash. Save the external stylesheet as your css if you want to edit or amend it. See [docs](https://dash.plotly.com/external-resources) for more. 

### Handling data

Data are just stored and read from the 'processed' data folder, so you need to run the read_*.py files before deploying if updating data (for now). Try a data class that reads everything in, joins it, and stores it in a temp div for later access. There are also constants in the code (e.g., Focal Area names) that are just stored as code, which could be improved.

### Deploying to Heroku

I deployed as soon as the structure was built to make it easier to debug the deployment. Here are the steps:

* Make sure app.py includes (after defining variable app)

  ```python
  server = app.server
  ```

* Create Procfile with contents. We're running from index, rather than app.

  ```
  web: gunicorn index:server
  ```

  Note no space after `index:`

* Install gunicorn if not already installed

  ```bash
  pip install gunicorn
  ```

  Create requirements.txt

  * `pip freeze>requirements.txt`
  * You can also list the key dependencies in a text file called requirements.txt. Should set up a pip or conda environment though.

* Create a heroku project

* ```bash
  heroku create <app name>
  ```

* Use Heroku to deploy

  ```bash
  git add .
  git commit -m "<message>"
  git push origin master
  heroku create <app name>
  git push heroku master
  heroku ps:scale web=1
  ```

* Be sure to update the requirements file as you go if you add new libraries.

### Tracking with Google Analytics

To track with Google Analytics, set up a new web property on Google Analytics, get the script, and paste it into the header tag in `index.py`.

```python
app.index_string = '''
<!DOCTYPE html>
<html>
    <head>
        {%metas%}
        <title>Utilization Report</title>
        {%favicon%}
        {%css%}
        
        <!-- Global site tag (gtag.js) - Google Analytics -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=UA-151885346-2"></script>
        <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', 'UA-151885346-2');
        </script>

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
```



