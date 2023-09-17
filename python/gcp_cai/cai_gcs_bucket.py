from google.cloud import asset_v1

def export_to_gcs_bucket():
    # Create a client 
    client = asset_v1.AssetServiceClient()

    # Creating a outputConfiguration based on 
    # https://cloud.google.com/python/docs/reference/cloudasset/latest/google.cloud.asset_v1.types.OutputConfig
    output_config = asset_v1.types.OutputConfig()
    output_config.gcs_destination.uri = "gs://my-bucket-information-11826735"
    
    request = asset_v1.ExportAssetsRequest(
        parent="my-project-name",
        
        
        # Asset content type.
        # Values: 
        #   CONTENT_TYPE_UNSPECIFIED (0): Unspecified content type. 
        #   RESOURCE (1): Resource metadata. 
        #   IAM_POLICY (2): The actual IAM policy set on a resource. 
        #   ORG_POLICY (4): The organization policy set on an asset. 
        #   ACCESS_POLICY (5): The Access Context Manager policy set on an asset. 
        #   OS_INVENTORY (6): The runtime OS Inventory information. 
        #   RELATIONSHIP (7): The related resources.
        #
        content_type="RESOURCE",
        output_config=output_config
    )
    
    operation = client.export_assets(request=request)
    return operation.result()


if __name__ == '__main__':
    export_to_gcs_bucket