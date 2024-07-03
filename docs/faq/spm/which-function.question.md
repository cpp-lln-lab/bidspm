---
title: "How do I know which matlab function performs a given SPM process?"
---

If you are looking for which SPM function does task X, click on the `help`
button in the main SPM menu window, then on the task X (e.g Results): the new
window will tell you the name of the function that performs the task you are
interested in (`spm_results_ui.m` in this case).

Another tip is that usually when you run a given process in SPM, the command
line will display the main function called.

For example clicking on the `Check Reg` button and selecting an image to view
display:

```matlab
SPM12: spm_check_registration (v6245)              13:42:08 - 30/10/2018
========================================================================
Display D:\SPM\spm12\canonical\avg305T1.nii,1
```

This tells you that this called the `spm_check_registration.m` matlab function.

You can also find other interesting suggestions in this discussion of the SPM
mailing list:
[Peeking under the hood -- how?](https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1803&L=spm&P=R58295&1=spm&9=A&J=on&d=No+Match%3BMatch%3BMatches&z=4).

Once you have identified the you can then type either type `help function_name`
if you want some more information about this function or `edit function_name` if
you want to see the code and figure out how the function works.
