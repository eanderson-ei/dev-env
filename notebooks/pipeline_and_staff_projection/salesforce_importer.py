import pandas as pd
from simple_salesforce import Salesforce
from login import *

sf = Salesforce(username=username,
                password=password,
                security_token=security_token,
                instance_url=instance,
                sandbox=isSandbox)

