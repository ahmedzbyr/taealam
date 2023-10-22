# Importing required libraries
import base64  # Importing base64 library for encoding/decoding operations

# Importing Mock from unittest.mock for creating mock objects
from unittest.mock import Mock
from unittest import mock
import unittest
import ds_export_cf  # Importing the module under test
from google.longrunning import operations_pb2
import json

# Creating a mock object for context which would be used to simulate Cloud Function's context
mock_context = Mock()

# Assigning a mock event_id to the context
mock_context.event_id = "123456789012345"

# Assigning a mock timestamp to the context
mock_context.timestamp = "2023-10-21T19:00:00.000Z"


def mocked_requests_get(*args, **kwargs):
    class MockResponse:
        def __init__(self, json_data):
            self.json_data = json_data

        def json(self):
            return self.json_data
    print(str(args[0]))
    return MockResponse('response')


class TestDatastoreExport(unittest.TestCase):

    # Defining the test function, capsys is a pytest fixture capturing stdout and stderr
    @mock.patch('ds_export_cf.datastore_admin_v1.DatastoreAdminClient.export_entities', side_effect=mocked_requests_get)
    def test_export(self, mock_get):

        # Specifying the Google Cloud Storage bucket where exported data will be stored
        bucket = "gs://my-bucket"
        # Formatting JSON string to include bucket info
        json_string = '{{ "export_bucket": "{bucket}" , "project_id" : "my_project" }}'.format(
            bucket=bucket)

        data = bytes(json_string, "utf-8")  # Encoding JSON string to bytes
        data_encoded = base64.b64encode(data)  # Base64 encoding the data
        # Creating an event dict with encoded data
        event = {"data": data_encoded}

        mockDatastore = Mock()  # Creating a mock object for Datastore client
        # Replacing the client in ds_export_cf with the mock object
        ds_export_cf.client = mockDatastore

        # Calling the function under test with mock objects
        ds_export_cf.datastore_export_entities(event, mock_context)
        # out, err = capsys.readouterr()  # Capturing stdout and stderr

        # Retrieving the arguments with which export_entities was called

        export_args = mockDatastore.export_entities.call_args[0]

        # Asserting that the bucket in request args is as expected

        # assert export_args["request"].output_url_prefix == bucket
        self.assertEqual(export_args["request"].output_url_prefix, bucket)

    # def test_datastore_export_entity_filter(self):
    #     # Test an export with an entity filter
    #     bucket = "gs://my-bucket"
    #     kinds = "Users,Tasks"
    #     namespaceIds = "Customer831,Customer157"
    #     json_string = '{{ "export_bucket": "{bucket}", "kinds": "{kinds}", "namespaceIds": "{namespaceIds}", "project_id" : "my_project" }}'.format(
    #         bucket=bucket, kinds=kinds, namespaceIds=namespaceIds
    #     )

    #     # Encode data like Cloud Scheduler
    #     data = bytes(json_string, "utf-8")
    #     data_encoded = base64.b64encode(data)
    #     event = {"data": data_encoded}

    #     # Mock the Datastore service
    #     mockDatastore = Mock()
    #     ds_export_cf.client = mockDatastore

    #     # Call tested function
    #     mockDatastore.export_entities.return_value = {
    #         "request": {
    #             "output_url_prefix": bucket,
    #             "project_id": "my_project"
    #         }
    #     }
    #     ds_export_cf.datastore_export_entities(event, mock_context)
    #     # out, err = capsys.readouterr()
    #     export_args = mockDatastore.export_entities.call_args[1]
    #     # Assert request includes test values

    #     assert export_args["request"].output_url_prefix == bucket
    #     assert export_args["request"].entity_filter.kinds == kinds
    #     assert export_args["request"].entity_filter.namespace_ids == namespaceIds


if __name__ == '__main__':
    unittest.main()
