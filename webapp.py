import boto3
import time
import logging
import uuid
from boto3.dynamodb.conditions import Key
def my_handler(event, context):
    message = event
    expiryTimestamp = int(time.time() +300)
    client = boto3.resource('dynamodb')
    table = client.Table("csye6225")
    username = event['Records'][0]['Sns']['MessageAttributes']['username']['Value']
    token = event['Records'][0]['Sns']['MessageAttributes']['token']['Value']
    try:
        response = table.scan()
        for i,j in response.items():
            if i=='Items':
                for m in j:
                    for y,z in m.items():
                        if y=='username' and z==username:
                            return 0
    except Exception as e:
        print(e)
    else:
        id=uuid.uuid1()
        table.put_item(Item= {'id':str(id) ,'username':  username , 'token':token , 'TimeToExist': (expiryTimestamp) })
        SENDER = "help@prod.abhithakkar.me"
        RECIPIENT = username
        AWS_REGION = "us-east-1"
        SUBJECT = "Link to Reset Password"
        BODY_TEXT = ("Change your password using this link: prod.abhithakkar.me/?email={email}&token={token}".format(email=username,token=token))
        CHARSET = "UTF-8"
        emailclient = boto3.client('ses',region_name=AWS_REGION)
        response = emailclient.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    
    return(message)