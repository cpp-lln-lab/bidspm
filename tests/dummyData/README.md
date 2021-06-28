# Dummy data for CPP_SPM

## How to truncate data files to 0kb

The following was taken from the BIDS example repo documentation.

---

You can always write a custom script in your favorite programming language,
but if you need a quick and simple way and have access to a unix based machine
(e.g., OSX, Linux), you can use the `find` command line tool:

```Bash
find <path_to_ds> -type f -name '*.nii' -exec truncate -s 0 {} +
```

which means:
- in this directory `<path_to_ds>`
- ... find everything of type "file" (or specify `d` for directory, ...)
- [optional] ... use `-name` with wildcard `*` to match to particular file types
- ... for each file, execute something
- ... namely, truncate the file
- ... to size 0
- `{}` is where a file name is put automatically (do not modify it)
- `+` means, this is performed not file-wise but with a bunch of files at once.
  Could also be `\;` to have it one after the other

---
