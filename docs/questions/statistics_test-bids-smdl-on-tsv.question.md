---
title: "Statistics: How can I see what the transformation in the BIDS stats model will do to my events.tsv?"
---

You can use the `bids.util.plot_events` function to help you visualize what events will be used in your GLM.

If you want to vivualize the events file:

```matlab
bids.util.plot_events(path_to_events_files);
```

This assumes the events are listed in the `trial_type` column (though this can be
changed by the `trial_type_col` parameter).

If you want to see what events will be included in your GLM after the transformations
are applied:

```matlab
bids.util.plot_events(path_to_events_files, 'model_file', path_to_bids_stats_model_file);
```

This assumes the transformations to apply are in the root node eof the model.

In case you want to save the output after the transformation:

```matlab
% load the events and the stats model
data = bids.util.tsvread(path_to_events_files);
model = BidsModel('file', path_to_bids_stats_model_file);

% apply the transformation
transformers = model.Nodes{1}.Transformations.Instructions;
[new_content, json] = bids.transformers(transformers, data);

% save the new TSV for inspection to make sure it looks like what we expect
bids.util.tsvwrite(fullfile(pwd, 'new_events.tsv'), new_content);
```
