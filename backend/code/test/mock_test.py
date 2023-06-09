from os import environ
import json
from datetime import datetime
from unittest import TestCase
import yaml
import boto3
from boto3.dynamodb.conditions import Key
import moto


DEFAULT_REGION="us-east-1"

# Import the handler under test
import app

# Mock the DynamoDB Service during the test
@moto.mock_dynamodb

class TestLambdaWithDynamoDB(TestCase):
    
    def setUp(self) -> None:

        # Create a name for a test table, and set the environment
        self.test_table_name = "views"
        
        environ["DYNAMODB_TABLE_NAME"] = self.test_table_name 

        # Create a mock table using the definition from the YAML template
        template_table_properties = self.read_template()["Resources"]["DynamoDBTable"]["Properties"]
        
        self.mock_dynamodb = boto3.resource("dynamodb", region_name=DEFAULT_REGION)
        
        self.mock_dynamodb_table = self.mock_dynamodb.create_table(
                TableName = self.test_table_name,
                KeySchema = template_table_properties["KeySchema"],
                AttributeDefinitions = template_table_properties["AttributeDefinitions"],
                BillingMode = template_table_properties["BillingMode"]
                )

        # Populate data for the tests
        self.mock_dynamodb_table.put_item(Item={'id'  : "1",
                                                'views'  : 0})
        
    def tearDown(self) -> None:
        self.mock_dynamodb_table.delete()
        del environ['DYNAMODB_TABLE_NAME']

    def read_template(self, sam_template_fn : str = "test/template.yaml" ) -> dict:
        with open(sam_template_fn, "r") as fp:
            template =fp.read().replace("!","")
            return yaml.safe_load(template)

    def test_lambda_handler(self):

        test_return = app.lambda_handler(event=None,context=None)

        self.assertEqual( test_return["statusCode"] , 200)

        # Verify the log entries
        items = self.mock_dynamodb_table.query(
            KeyConditionExpression=Key('id').eq('1')
        )

        # Log entry item to the original name item
        self.assertEqual( len(items["Items"]) , 1)

        #Check the log entry item
        self.assertGreater(items["Items"][0]["views"], 0)
