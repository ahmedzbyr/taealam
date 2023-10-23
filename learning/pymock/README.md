# Running Mock Tests

```
nose2 datastoreExport
```

output

```
┌─(.venv)[ahmedzbyr][Zubairs-MacBook-Pro][~/projects/pymock]
└─▪ nose2 datastoreExport
{ "export_bucket": "gs://my-bucket" , "project_id" : "my_project" }
Waiting for operation to complete...
<Mock name='mock.export_entities().result()' id='4501527648'>
gs://my-bucket
.Waiting for operation to complete...
<Mock name='mock.export_entities().result()' id='4501855088'>
.
----------------------------------------------------------------------
Ran 2 tests in 0.006s

OK
```