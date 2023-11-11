# Import necessary libraries
import base64
import json
import os
import datetime

# Import Google Cloud Datastore Admin Client
from google.cloud import firestore_admin_v1
# Create a client instance to connect to Google Cloud Datastore admin service.
client = firestore_admin_v1.FirestoreAdminClient()

#
# More information about the example in below URL, using the example here to modify further for Cloud function.
# https://cloud.google.com/python/docs/reference/firestore/latest/google.cloud.firestore_admin_v1.services.firestore_admin.client.FirestoreAdminClient#google_cloud_firestore_admin_v1_services_firestore_admin_client_FirestoreAdminClient_export_documents
#

# Exports a copy of all or a subset of documents from Google Cloud Firestore to another storage system, such as Google Cloud Storage.
#   Recent updates to documents may not be reflected in the export.
#   The export occurs in the background and its progress can be monitored and managed via the Operation resource that is created.
#   The output of an export may only be used once the associated operation is done.
#   If an export operation is cancelled before completion it may leave partial data behind in Google Cloud Storage.
# For more details on export behavior and output format, refer to:
# https://cloud.google.com/firestore/docs/manage-data/export-import

#
# Define a JSON payload expected from Cloud Scheduler or Cloud Function
#
json_data = {
    "project_id": "my-project-id",
    "db_id": "db_id",
    "export_bucket": "gs://fs-export-bucket/",
    "collection_ids": ["abc", "xyz", "axz"],
    "namespace_ids": ["my_nm"]
}


def round_time(dt=None, date_delta=datetime.timedelta(minutes=1), to='down'):
    """
    Round a datetime object to a multiple of a timedelta
    dt : datetime.datetime object, default now.
    dateDelta : timedelta object, we round to a multiple of this, default 1 minute.
    from:  http://stackoverflow.com/questions/3463930/how-to-round-the-minute-of-a-datetime-object-python
    """
    round_to = date_delta.total_seconds()
    if dt is None:
        dt = datetime.datetime.now()
    seconds = (dt - dt.min).seconds

    if seconds % round_to == 0 and dt.microsecond == 0:
        rounding = (seconds + round_to / 2) // round_to * round_to
    else:
        if to == 'up':
            # // is a floor division, not a comment on following line (like in javascript):
            rounding = (seconds + dt.microsecond/1000000 +
                        round_to) // round_to * round_to
        elif to == 'down':
            rounding = seconds // round_to * round_to
        else:
            rounding = (seconds + round_to / 2) // round_to * round_to

    return (dt + datetime.timedelta(0, rounding - seconds, - dt.microsecond)).isoformat("T")


def firestore_export(event, context):

    # Check if the event contains 'data' field which is expected when triggered via Cloud Scheduler.
    # If so, decode the inner data field of the JSON payload.
    if "data" in event:
        json_data = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    else:
        # If not, (e.g., if triggered via Cloud Console on a Cloud Function), the event itself is the data.
        json_data = json.loads(event)

    request = firestore_admin_v1.ExportDocumentsRequest(
        name="projects/"+json_data["project_id"] +
        "/databases/" + json_data["db_id"],
        output_uri_prefix=json_data["export_bucket"] + str(round_time()) + "Z",
        collection_ids=json_data["collection_ids"] if json_data.get(
            "collection_ids") else []
        # namespace_ids=json_data["namespace_ids"] if json_data.get(
        #     "namespace_ids") else [],
        # snapshot_time=json_data["snapshot_time"] if json_data.get(
        #     "snapshot_time") else str(round_time()) + "Z"
    )

    # Make the request to export entities from Google Cloud Datastore.
    # This method returns an operation object which can be used to track the progress of the request.
    operation = client.export_documents(request=request)

    # Print a message indicating that the operation is in progress.
    print("Waiting for operation to complete...")

    # Wait for the operation to complete and retrieve the result.
    # This will block until the operation is complete.
    response = operation.result()

    # Handle the response.
    # In this case, print the JSON representation of the response to the console.
    print(response)


if __name__ == "__main__":
    print("Running the function using the JSON below..")
    print("-------------------------------------------")
    print(json.dumps(json_data, indent=2))
    # firestore_export(json.dumps(json_data), None)
