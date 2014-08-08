# `collection_audio_view.csv` is dumped from the latin1 db

default: stops.min.json audio-stops.min.json

stops.csv: collection_audio_view.csv
	in2csv -e iso-8859-1 collection_audio_view.csv | \
			csvfix lower -f 4 | \
			csvfix order -f 1:2,4,3,5:10 > stops.csv

stops.json: stops.csv
	csvjson stops.csv | jq 'map({(.object_id): .}) | add' > stops.json

audio-stops.json: stops.csv
	csvjson stops.csv | jq 'map({(.audio_stop_number): .}) | add' > audio-stops.json

stops.min.json: stops.json
	jq -c '.' < stops.json > stops.min.json

audio-stops.min.json: audio-stops.json
	jq -c '.' < audio-stops.json > audio-stops.min.json

install:
	pip install csvkit
	brew install csv-fix jq

# Add audio stops to our collection redis.
# `objects:<id>:audio` is a set made up of audio stop filenames.
redis:
	cat stops.csv | \
			sed -e 's/,,/, ,/g' | \
			column -s, -t | \
			while read stop_id object_id file title; do \
			echo redis-cli sadd objects:$$object_id:audio $$file | sed 's/"//g' | sh; \
			done
