# Slow tests folders

Move files in this folder if they are too slow.

Add the following at the beginning of each test.

```matlab
  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end
```
