---
title: "SPM: How can get the data from some specific voxel in a nifti image?"
---

### `spm_read_vols`

This can be done with the `spm_read_vols` function.

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
% get the data
data = spm_read_vols(header);
```

`data` is an array of size (x, y, z, t) with x, y and z being the spatial dimensions
and t being the temporal dimension.

You can access the data in any voxel by using the proper index.

### `spm_get_data`

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
% define voxels to return
XYZ = [10 20; ...
       20 25; ...
       39 10];
% get the data
data = spm_get_data(header, XYZ)
```

- `header`         - [1 x n] structure array of file headers with `n` being the number of volumes
- `XYZ`       - [3 x m] or [4 x m] location matrix {voxel}

- `data`      - [n x m] double values
