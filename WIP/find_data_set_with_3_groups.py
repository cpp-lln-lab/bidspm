from pathlib import Path

import pandas as pd
from pandas.errors import ParserError

openneuro = Path("/home/remi/datalad/datasets.datalad.org/openneuro")

for ds in openneuro.iterdir():
    file = ds / "participants.tsv"

    if file.exists():

        try:
            df = pd.read_csv(file, sep="\t")
        except ParserError:
            ...

        if len(df) < 10:
            continue
        if "group" in df.columns:
            col = "group"
        elif "Group" in df.columns:
            col = "Group"
        else:
            continue
        if len(df[col].value_counts()) < 3:
            continue
        if "age" in df.columns and df["age"].mean() < 18:
            continue
        bold_files = list(ds.glob("**/*bold*"))

        has_func = len(bold_files) > 0
        if not has_func:
            continue

        tasks = {x.name.split("task-")[1].split("_")[0] for x in bold_files}
        if len(tasks) == 1 and "rest" in tasks:
            continue

        print()
        print(file)
        print(df[col].value_counts())
        print(tasks)
