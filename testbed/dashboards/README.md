# Dashboards

## Export
```
curl http://localhost:8888/chronograf/v1/dashboards | jq '.' > <JSON_FILE>
```

## Import
```
cat <JSON_FILE> \
	| jq -r '.dashboards[]' \
	| curl \
	  --silent \
	  --include \
	  --request POST \
	  --header "Accept: application/json" \
	  --dump-header - \
	  --data @- \
	  --output /dev/null \
	  http://localhost:8888/chronograf/v1/dashboards
```

## Removal
```
curl -v -X DELETE http://localhost:8888/chronograf/v1/dashboards/<DASHBOARD_ID>
```
