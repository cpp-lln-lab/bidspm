---
title: "How can I run bidspm from the command line?"
---

You can use the Python CLI of bidspm to run many functionalities from the terminal.

See the README to see how to install it.

You can also run your matlab script from within your terminal
without starting the MATLAB graphic interface.

For this you first need to know where is the MATLAB application.
Here are the typical location depending on your operating system
(where `XXx` corresponds to the version you use).

-   Windows: `C:\Program Files\MATLAB\R20XXx\bin\matlab.exe`
-   Mac: `/Applications/Matlab_R20XXx.app/bin/matlab`
-   Linux: `/usr/local/MATLAB/R20XXx/bin/matlab`

You can then launch MATLAB from a terminal in a command line only
with the following arguments: `-nodisplay -nosplash -nodesktop`

So on Linux for example:

```bash
/usr/local/MATLAB/R2017a/bin/matlab -nodisplay -nosplash -nodesktop
```

If you are on Mac or Linux, we would recommend adding those aliases to your
`.bashrc` or wherever else you keep your aliases.

```bash
matlab=/usr/local/MATLAB/R20XXx/bin/matlab
matlabcli='/usr/local/MATLAB/R20XXx/bin/matlab -nodisplay -nosplash -nodesktop'
```
