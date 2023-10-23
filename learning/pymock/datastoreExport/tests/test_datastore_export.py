# Importing required libraries and modules
from unittest.mock import Mock, patch
import base64

# Importing the datastore_export module from the local directory
from datastoreExport import datastore_export

# Creating a mock object for context
# Setting event_id and timestamp attributes for the mock context object
mock_context = Mock()
mock_context.event_id = "123456789012345"
mock_context.timestamp = "2023-10-23T22:00:00.000Z"

# Mocking the export_entities method of the DatastoreAdminClient class
# This is done to isolate the unit of work from external dependencies we dont want to execute the API


@patch('google.cloud.datastore_admin_v1.DatastoreAdminClient.export_entities')
def test_datastore_export(mock_get):
    # Defining the bucket URL
    bucket = "gs://my-bucket"
    # Creating a JSON string with the bucket URL and project ID
    json_string = '{{ "export_bucket": "{bucket}" , "project_id" : "my_project" }}'.format(
        bucket=bucket)

    # Creating a mock object for the Datastore client
    mockDatastore = Mock()
    # Replacing the client attribute of the datastore_export module with the mock object
    datastore_export.client = mockDatastore

    # Invoking the datastore_export method with the JSON string and mock context as arguments
    datastore_export.datastore_export(json_string, mock_context)

    # Retrieving the arguments passed to the export_entities method of the mock client object
    #  This is a request to the API, which we are checking.
    export_args = mockDatastore.export_entities.call_args[1]

    # Asserting that the output_url_prefix attribute of the request object is set to the bucket URL
    assert export_args["request"].output_url_prefix == "gs://my-bucket", "Response should not be None."


# Mocking the export_entities method of the DatastoreAdminClient class again for a different test case
@patch('google.cloud.datastore_admin_v1.DatastoreAdminClient.export_entities')
def test_datastore_export_entity_filter(mock_get):
    # Defining test values for the bucket URL, entity kinds, and namespace IDs
    bucket = "gs://my-bucket"
    kinds = ['default', 'customers']
    namespace_ids = ['projectA', 'projectB']
    # Creating a JSON string with the test values
    json_string = '{{ "export_bucket": "{bucket}", "kinds": "{kinds}", "namespace_ids": "{namespace_ids}" , "project_id" : "my_project"}}'.format(
        bucket=bucket, kinds=str(kinds), namespace_ids=str(namespace_ids)
    )

    # Creating a mock object for the Datastore client
    mockDatastore = Mock()

    # Replacing the client attribute of the datastore_export module with the mock object
    datastore_export.client = mockDatastore

    # Invoking the datastore_export method with the JSON string and mock context as arguments
    datastore_export.datastore_export(json_string, mock_context)

    # Retrieving the arguments passed to the export_entities method of the mock client object
    #  This is a request to the API, which we are checking.
    export_args = mockDatastore.export_entities.call_args[1]

    # Asserting that the request object includes the test values
    assert export_args["request"].output_url_prefix == bucket
    assert export_args["request"].entity_filter.kinds == str(kinds)
    assert export_args["request"].entity_filter.namespace_ids == str(
        namespace_ids)
