# Import necessary libraries
import base64
import json
import os

# Import Google Cloud Datastore Admin Client
from google.cloud import datastore_admin_v1

#
# More information about the example in below URL, using the example here to modify further for Cloud function.
# https://cloud.google.com/python/docs/reference/datastore/latest/google.cloud.datastore_admin_v1.services.datastore_admin.client.DatastoreAdminClient#google_cloud_datastore_admin_v1_services_datastore_admin_client_DatastoreAdminClient_export_entities
#

#
# Export/Import Service:
#
# - The Export/Import service provides the ability to copy all or a subset of entities to/from Google Cloud Storage.
# - Exported data may be imported into Cloud Datastore for any Google Cloud Platform project. It is not restricted to the export source project. It is possible to export from one project and then import into another.
# - Exported data can also be loaded into Google BigQuery for analysis.
# - Exports and imports are performed asynchronously. An Operation resource is created for each export/import. The state (including any errors encountered) of the export/import may be queried via the Operation resource.
#

#
# Define a JSON payload expected from Cloud Scheduler or Cloud Function
#
json_data = {
    "project_id": "elevated-column-400011",
    "export_bucket": "gs://ds-export-bucket/",
    "kinds": ["abc", "xyz", "axz"],
    "namespace_ids": ["my_nm"]
}


def datastore_export_entities(event, context):
    # Create a client instance to connect to Google Cloud Datastore admin service.
    client = datastore_admin_v1.DatastoreAdminClient()

    # Check if the event contains 'data' field which is expected when triggered via Cloud Scheduler.
    # If so, decode the inner data field of the JSON payload.
    if "data" in event:
        json_data = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    else:
        # If not, (e.g., if triggered via Cloud Console on a Cloud Function), the event itself is the data.
        json_data = event

    #
    # Set up the entity filter based on the documentation provided in the URL.
    # This filter helps in exporting specific kinds and/or namespaces from the Datastore.
    #
    # https://cloud.google.com/datastore/docs/reference/admin/rpc/google.datastore.admin.v1#google.datastore.admin.v1.EntityFilter
    # Entire project: kinds=[], namespace_ids=[]
    # Kinds Foo and Bar in all namespaces: kinds=['Foo', 'Bar'], namespace_ids=[]
    # Kinds Foo and Bar only in the default namespace: kinds=['Foo', 'Bar'], namespace_ids=['']
    # Kinds Foo and Bar in both the default and Baz namespaces: kinds=['Foo', 'Bar'], namespace_ids=['', 'Baz']
    # The entire Baz namespace: kinds=[], namespace_ids=['Baz']
    #
    entity_filter = datastore_admin_v1.EntityFilter()
    entity_filter.kinds = json_data["kinds"] if json_data.get("kinds") else []
    entity_filter.namespace_ids = json_data["namespace_ids"] if json_data.get(
        "namespace_ids") else []

    # Set up the request arguments for exporting entities.
    # 'project_id' specifies the GCP project ID.
    # 'output_url_prefix' specifies the GCS location where the exported data will be stored.
    # 'entity_filter' specifies which kinds and/or namespaces should be exported.
    # https://cloud.google.com/datastore/docs/reference/admin/rpc/google.datastore.admin.v1#google.datastore.admin.v1.ExportEntitiesRequest
    #
    request = datastore_admin_v1.ExportEntitiesRequest(
        project_id=json_data["project_id"],
        output_url_prefix=json_data["export_bucket"],
        entity_filter=entity_filter
    )

    # Make the request to export entities from Google Cloud Datastore.
    # This method returns an operation object which can be used to track the progress of the request.
    operation = client.export_entities(request=request)

    # Print a message indicating that the operation is in progress.
    print("Waiting for operation to complete...")

    # Wait for the operation to complete and retrieve the result.
    # This will block until the operation is complete.
    # response = operation.result()

    # Handle the response.
    # In this case, print the JSON representation of the response to the console.
    print(operation)
