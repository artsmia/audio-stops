# `collection_audio_view.csv` is dumped from the latin1 db

stops.csv: collection_audio_view.csv
	in2csv -e iso-8859-1 collection_audio_view.csv | \
		csvfix lower -f 4 | \
		csvfix edit -e 's#\(.*.mp3\)#http://audio-tours.s3.amazonaws.com\/\1#' -f 4 | \
		csvfix order -f 1:2,4,3,5:10 > stops.csv

stops.json: stops.csv
	csvjson stops.csv | jq 'map({(.object_id): .}) | add' > stops.json

stops.min.json: stops.json
	jq -c '.' < stops.json > stops.min.json

install:
	pip install csvkit
	brew install csv-fix jq
