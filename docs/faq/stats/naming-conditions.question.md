---
title: "How should I name my conditions in my events.tsv?"
---

In BIDS format, conditions should be named in the `trial_type` column of the `events.tsv` file.

Some good practices for naming "things" can probably be applied here.

- use only alphanumeric characters, underscores and hyphens,
avoid spaces in the condition names

For example: `foo_bar` is ok, but `f$o}o b^a*r` is not.

- the condition names should be short AND descriptive AND human readable

For example: `1` or `one` or `condition1` are short but not descriptive.

An extra requirement to have condition names that can work with bidspm
is that condition names ending with an underscore followed by one or more digits
may lead to unwanted behavior (error or nothing happening
- see [issue](https://github.com/cpp-lln-lab/bidspm/issues/973))
when computing results of a GLM.

So for example:

`happy_face1` and `house123` are ok, but `happy_face_1` and `house_123`  are not.

If your BIDS dataset has conditions that do not follow this rule,
then you can use
the [`Replace` variable transform](https://github.com/bids-standard/variable-transform/blob/main/spec/munge.md#replace)
in your [BIDS statistical model](https://bidspm.readthedocs.io/en/latest/bids_stats_model.html#transformation')
to rename them on the fly without having to manually edit potentially dozens of files.

See also example below.

Say one of your events.tsv files looks like this:

|   onset |   duration | trial_type   |
|--------:|-----------:|:-------------|
|       2 |          2 | happy_face_1 |
|       4 |          2 | house_2      |
|       5 |          2 | happy_face_2 |
|       8 |          2 | house_4      |

You can add the following transformation to the first node (usually the run level node)
of your BIDS stats model.

```json
{
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
      "GroupBy": [
        "run",
        "subject"
      ],
      "Transformations": {
        "Description": "Replace",
        "Instruction": [
            {
                "Name": "Replace",
                "Input": "trial_type",
                "Replace": [
                    {
                        "key": "happy_face_1",
                        "value": "happy_face1"
                    },
                    {
                        "key": "house_2",
                        "value": "house2"
                    },
                    {
                        "key": "happy_face_2",
                        "value": "happy_face2"
                    },
                    {
                        "key": "house_4",
                        "value": "house4"
                    }
                ]
            }
        ]
    },
      "Model": {
        "X": [
            "trial_type.happy_face*",
            "trial_type.house*"
          ],
        "Description": "the rest of the bids stats model would go below this as usual."

    }
    }
  ]
}
```

Related issue: https://github.com/cpp-lln-lab/bidspm/issues/973
