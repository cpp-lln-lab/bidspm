---
title:
    "General: How can I prevent from having SPM windows pop up all the time?"
---

Running large number of batches when the GUI of MATLAB is active can be
annoying, as SPM windows will always pop up and become active instead of running
in the background like most users would prefer to.

One easy solution is to add a `spm_my_defaults` function with the following
content in the MATLAB path, or in the directory where you are running your
scripts or command from.

```matlab
function spm_my_defaults

  global defaults

  defaults.cmdline = true;

end
```

This should be picked up by bidspm and SPM upon initialization and ensure that
SPM runs in command line mode.
