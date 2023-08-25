versions:
	# aws rds describe-db-engine-versions --output json --query 'DBEngineVersions[*].{Engine:Engine,EngineVersion:EngineVersion}' > rds-db-versions.json
	./gen_engine_version_table.py rds-db-versions.json > preferred_engine_versions.json
	jq -Sr . < preferred_engine_versions.json

pr:
	@if ! git diff --stat --exit-code preferred_engine_versions.json; then \
		echo; \
		change=$$(git diff -U0 preferred_engine_versions.json | grep '^[+]' | grep -Ev '^(--- a/|\+\+\+ b/)' | cut -d" " -f3-); \
		git add preferred_engine_versions.json; \
		git commit -m "RDS DB Version Update: $$change"$$'\n'"preferred_engine_versions updated: $$change"; \
		echo gh pr create -r "@oneTakeda/dbcoeteam" -a "@oneTakeda/dbcoeteam" \
			-f -l service-standard-change; \
	fi
