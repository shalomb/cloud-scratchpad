#!/usr/bin/env python3

import json
import re
import sys

input_file = sys.argv[1]


def read_data():
    with open(input_file) as f:
        content = f.read()
    return json.loads(content)


def parse_version(v):
    v = v.split(".")
    return {
        "maj": v[0],
        "min": v[1],
        "patch": v[2] if len(v) > 2 else "",
    }


db_versions = {}

for line in read_data():
    db_versions[line["Engine"]] = line["EngineVersion"]

output = {}
for engine in [
    "mariadb",
    "mysql",
    "oracle-ee",
    "oracle-se2",
    "postgres",
    "sqlserver-ee",
    "sqlserver-se",
]:
    v = parse_version(db_versions[engine])

    # default case
    version = f"{v['maj']}"

    if "oracle" in engine:
        version = f"{v['maj']}"
    if re.match("mysql|postgres|sqlserver", engine):
        version = f"{v['maj']}.{v['min']}"
    if "mariadb" in engine:
        version = f"{v['maj']}.{v['min']}.{v['patch']}"
    output[engine] = version

print(json.dumps(output, sort_keys=True, indent=2))
