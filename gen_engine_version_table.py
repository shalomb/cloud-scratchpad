#!/usr/bin/env python3

import json
import sys

requirements = {
    "mariadb": "maj.min.patch",
    "mysql": "maj.min",
    "oracle-ee": "maj",
    "oracle-se2": "maj",
    "postgres": "maj.min",
    "sqlserver-ee": "maj.min",
    "sqlserver-se": "maj.min",
}

input_file = sys.argv[1]


def read_data():
    with open(input_file) as f:
        content = f.read()
    return json.loads(content)


def fmt_version(v, fmt):
    v = v.split(".")
    t = {
        "maj": v[0],
        "min": v[1],
        "patch": v[2] if len(v) > 2 else "",
    }
    return ".".join([t[k] for k in fmt.split(".")])


db_versions = {item["Engine"]: item["EngineVersion"] for item in read_data()}

print(
    json.dumps(
        {k: fmt_version(db_versions[k], v) for k, v in requirements.items()},
        sort_keys=True,
        indent=2,
    )
)
