# `collection_audio_view.csv` is dumped from the latin1 db

stops.csv: collection_audio_view.csv
	iconv -f iso-8859-1 -t utf-8 < collection_audio_view.csv | \
			csvfix lower -f 4 > stops.csv

stops.json: stops.csv
	csvjson stops.csv | jq 'map({(.object_id): .}) | add' > stops.json

install:
	pip install csvkit
	brew install csv-fix jq
