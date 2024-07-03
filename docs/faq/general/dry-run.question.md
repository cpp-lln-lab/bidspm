---
title:
    "How can I know that things are set up properly before I run an analysis?"
---

If you want to set things up but not let SPM actually run the batches
you can use the option:

`dry_run, true()`

This can be useful when debugging.

You may still run into errors when SPM jobman takes over and starts running the batches,
but you can at least see if the batches will be constructed
without error and then inspect with the SPM GUI to make sure everything is fine.
