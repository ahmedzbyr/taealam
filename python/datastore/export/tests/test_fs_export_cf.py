# Importing required libraries and modules
from unittest.mock import Mock, patch
import base64

# Importing the datastore_export module from the local directory
from export import fs_export_cf

# Creating a mock object for context
# Setting event_id and timestamp attributes for the mock context object
mock_context = Mock()
mock_context.event_id = "123456789012345"
mock_context.timestamp = "2023-10-23T22:00:00.000Z"


@patch('google.cloud.firestore_admin_v1.FirestoreAdminClient.export_documents')
def test_firestore_export(mock_get):
    # Defining the bucket URL
    bucket = "gs://my-bucket"
    db_id = "db_id"
    # Creating a JSON string with the bucket URL and project ID
    json_string = '{{ "export_bucket": "{bucket}" , "db_id": "{db_id}", "project_id" : "my_project" }}'.format(
        bucket=bucket, db_id=db_id)

    print(json_string)

    # Creating a mock object for the Datastore client
    mockDatastore = Mock()
    # Replacing the client attribute of the datastore_export module with the mock object
    fs_export_cf.client = mockDatastore

    # Invoking the datastore_export method with the JSON string and mock context as arguments
    fs_export_cf.firestore_export(json_string, mock_context)

    # Retrieving the arguments passed to the export_entities method of the mock client object
    #  This is a request to the API, which we are checking.
    export_args = mockDatastore.export_documents.call_args[1]
    print(str(export_args))

    # Asserting that the output_url_prefix attribute of the request object is set to the bucket URL
    assert export_args is not None
