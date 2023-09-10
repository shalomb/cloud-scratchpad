#!/usr/bin/make -f

versions:
	# aws rds describe-db-engine-versions --output json --query 'DBEngineVersions[*].{Engine:Engine,EngineVersion:EngineVersion}' > rds-db-versions.json
	./gen_engine_version_table.py rds-db-versions.json | jq -S . > preferred_engine_versions.json

pr:
	@if ! git diff --stat --exit-code preferred_engine_versions.json; then \
		echo; \
		git diff -U0 preferred_engine_versions.json ; \
		engine=$$(git diff -U0 preferred_engine_versions.json | grep '^[-]' | grep -Ev '^(--- a/|\+\+\+ b/)' | cut -d" " -f3 | sed 's/[":,]//g'); \
		echo "$$line"; \
		old_ver=$$(git diff -U0 preferred_engine_versions.json | grep '^[-]' | grep -Ev '^(--- a/|\+\+\+ b/)' | cut -d" " -f4- | sed 's/[":,]//g'); \
		new_ver=$$(git diff -U0 preferred_engine_versions.json | grep '^[+]' | grep -Ev '^(--- a/|\+\+\+ b/)' | cut -d" " -f4- | sed 's/[":,]//g'); \
		echo git add preferred_engine_versions.json; \
		echo ; \
		echo git commit -m "RDS DB Version Update: $$old_ver -> $$new_ver" -m "preferred_engine_versions.json updated: $$ver"; \
		echo ; \
		echo gh pr create -r "@shalomb/dbcoeteam" -a "@shalomb/dbcoeteam" \
			-f -l service-standard-change; \
	fi
