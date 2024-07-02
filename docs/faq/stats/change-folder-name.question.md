---
title: "How can change the name of the folder of the subject level analysis?"
---

This can be done by changing the `Name` of the run level `Nodes`
in the BIDS stats model.

If your `Nodes.Name` is one of the "default" values:

- `"run"`
- `"run level"`
- `"run_level"`
- `"run-level"`
- ...

like in the example below

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "run_level",
    }
  ]
```

then {func}`src.stats.subject_level.getFFXdir.m` will set the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue
```

However if your `Nodes.Name` is not one of the "default" values, like this

```json
  "Nodes": [
    {
      "Level": "Run",
      "Name": "parametric",
    }
  ]
```

then the subject level folder to be named as follow:

```text
sub-subLabel
└── task-taskLabel_space-spaceLabel_FWHM-FWHMValue_node-parametric
```
