---
title: "SPM: How can set the value of a specific voxel in a nifti image?"
---

This can be done with the `spm_write_vols` function.

```matlab
% get nifti header
header = spm_vol(path_to_image);

% get atlas content
content = spm_read_vols(header);

% set the voxel (1,1,1) to 0
x = 1;
y = 1;
z = 1;
content(x,y, z) = 0;

% prepare header for the output
new_header = header;
new_header.fname = 'changed_nifti.nii';

% write mask
spm_write_vol(new_header, content);
```
