import json
import boto3
from os import environ
from datetime import datetime

def lambda_handler(event, context):


    # Retrieve the table name from the environment, and create a boto3 Table object
    try:
        dynamodb_table_name = environ["VIEWS_TABLE"]
    except:
        dynamodb_table_name="views"
#    if not dynamodb_table_name:
    
    dynamodb_resource = boto3.resource('dynamodb', region_name='us-east-1')
    dynamodb_table = dynamodb_resource.Table(dynamodb_table_name)
    print(f"Using DynamoDB Table {dynamodb_table_name}.")

    # Retrieve the views.
    dynamodb_response = dynamodb_table.get_item(Key={'id':'1'})

    # Does the views this id?
    if "Item" in dynamodb_response and "views" in dynamodb_response["Item"]:
        views = dynamodb_response["Item"]["views"]
        views = views + 1
        message = views
        status_code = 200
        headers = {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET'
        }
    else:
        message = "DynamooDB problem"
        status_code = 500

    # Create a timestamp and log the message back to DynamoDB
    datetime_stamp = "DT#" + datetime.now().strftime("%Y%m%dT%H%M%S.%f")
    dynamodb_table.put_item(Item={'id'  : "1",
                                  'views'  : views})

    # Log and return
    print(f"Message: {message} - {datetime_stamp}")

    return {
        "statusCode": status_code,
        "headers": headers,
        "body": message
    }
