

from google.cloud import firestore_admin_v1

#  WIP


def sample_export_documents():
    # Create a client
    client = firestore_admin_v1.FirestoreAdminClient()

    # Initialize request argument(s)
    request = firestore_admin_v1.ExportDocumentsRequest(
        name="name_value",
    )

    # Make the request
    operation = client.export_documents(request=request)

    print("Waiting for operation to complete...")

    response = operation.result()

    # Handle the response
    print(response)
