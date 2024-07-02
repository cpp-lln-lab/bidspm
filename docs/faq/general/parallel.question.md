---
title: "Can I use parallelization with bidspm?"
alt_titles:
    - "How can I speed up my analysis?"
---

You can use parallelization with bidspm.
The main way to do so is to use `parfor` loops in your code
when running the `preprocess`, `smooth` or `stats` actions.

For example, if you want to run the `preprocess` action on a list of subjects,

```matlab
subjects = {'01', '02', '03', '04', '05'};
parfor i = 1:length(subjects)
    bidspm(bids_dir, output_dir, ...
           'participant_label', subjects(i), ...
           'action', 'preprocess', ...
           'task', {'tasnName'}, ...
           'space', {'IXI549Space'});
end
```
