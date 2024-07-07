---
title:
    "How can I run bidspm only certain files, like just the session `02` for example?"
---

Currently there are 2 ways of doing this.

-   using the `bids_filter_file` parameter or an equivalent
    `bids_filter_file.json` file or its counterpart field `opt.bidsFilterFile`
-   using the `opt.query` option field.

On the long run the plan is to use only the `bids_filter_file`,
but for now both possibilities should work.

### `bids filter file`

This is similar to the way you can "select" only certain files to preprocess
with
[fmriprep](https://fmriprep.org/en/stable/faq.html#how-do-i-select-only-certain-files-to-be-input-to-fmriprep).

You can use a `opt.bidsFilterFile` field in your options to define a typical
images "bold", "T1w" in terms of their BIDS entities. The default value is:

```matlab
struct('fmap', struct('modality', 'fmap'), ...
       'bold', struct('modality', 'func', 'suffix', 'bold'), ...
       't2w',  struct('modality', 'anat', 'suffix', 'T2w'), ...
       't1w',  struct('modality', 'anat', 'space', '', 'suffix', 'T1w'), ...
       'roi',  struct('modality', 'roi', 'suffix', 'mask'));
```

Similarly when using the bidspm you can use the argument `bids_filter_file` to
pass a structure or point to a JSON file that would also define typical images
"bold", "T1w"...

The default content in this case would be:

```json
{
    "fmap": { "datatype": "fmap" },
    "bold": { "datatype": "func", "suffix": "bold" },
    "t2w":  { "datatype": "anat", "suffix": "T2w" },
    "t1w":  { "datatype": "anat", "space": "", "suffix": "T1w" },
    "roi":  { "datatype": "roi", "suffix": "mask" }
}
```

So if you wanted to run your analysis on say run `02` and `05` of session `02`,
you would define a json file this file like this:

```json
{
    "fmap": { "datatype": "fmap" },
    "bold": {
        "datatype": "func",
        "suffix": "bold",
        "ses": "02",
        "run": ["02", "05"]
    },
    "t2w": { "datatype": "anat", "suffix": "T2w" },
    "t1w": { "datatype": "anat", "space": "", "suffix": "T1w" },
    "roi": { "datatype": "roi", "suffix": "mask" }
}
```

### `opt.query`

You can select a subset of your data by using the `opt.query`.

This will create a "filter" that bids-matlab will use to only "query" and
retrieve the subset of files that match the requirement of that filter

In "pure" bids-matlab it would look like:

```matlab
  BIDS = bids.layout(path_to_my_dataset)
  bids.query(BIDS, 'data', opt.query)
```

So if you wanted to run your analysis on say run `02` and `05` of session `02`,
you would define your filter like this:

```matlab
  opt.query.ses = '02'
  opt.query.run = {'02', '05'}
```
