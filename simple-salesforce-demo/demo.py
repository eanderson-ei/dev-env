"""GROUP EDITION DOES NOT SUPPORT API CALLS, MUST UPGRADE TO PROFESSIONAL AND BUY ADD-ON"""

import json
import pandas as pd
from simple_salesforce import Salesforce, SalesforceLogin, SFType

loginInfo = json.load(open('secrets/login.json'))
username = "kriley@enviroincentives.com"  # loginInfo['username']
password = "incentives6"  # loginInfo['password']
security_token = "wgBVuHvxv5ROj4aqj5HpUT2ng"  # loginInfo['security_token']
domain = 'login'  # two types, 'login' and 'test'. Use test for sandbox


# easiest but don't use in production
# sf = Salesforce(username=username, password=password,
#                 security_token=security_token,
#                 domain=domain)

# more secure
session_id, instance = SalesforceLogin(username=username, password=password,
                                       security_token=security_token,
                                       domain=domain)

sf = Salesforce(instance=instance, session_id=session_id)

# print(sf))  # look for simple_salesforce.api.Saleforce object at <sha1-hash>

# define query
fields = [
    'Opportunity ID',
    'Opportunity Name',
    'EI Project Number',
    'Account Name',
    'Practice Area',
    'Stage',
    'Probability (%)',
    'Amount',
    'Value',
    'Close Date',
    'Expected Contract Length',
    'Last Stage Change Date'  # for closed won projects, this is date of close
]

query = """SELECT {} FROM Opportunity""".format(', '.join(fields))  # use * to get all fields

# # submit query
# response = sf.query(query)
# records = response.get('records')
# next_records_url = response.get('nextRecordsUrl')

# # get additional records if required (limit 200 per request)
# while not response.get('done'):
#     response = sf.query_more(next_records_url, identifier_is_url=True)
#     records.extend = response.get(response)
#     next_records_url = response.get('nextRecordsUrl')
    
# convenience method
response = sf.query_all(query)
records = response.get('records')
    
df = pd.DataFrame(records)

df.to_csv('opportunities.csv', index=False)
