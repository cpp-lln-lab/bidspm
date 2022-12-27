---
title: "SPM: How do I get the header of a nifti image?"
alt_titles:
  - "How do I find out the resolution of a nifti image?"
  - "How do I find out the voxel size of a nifti image?"
  - "How do I find out the voxel corresponding to the X, Y, Z coordinate in mm?"
---

### Getting the header

This can be done with the `spm_vol` function.

```matlab
% get header of Nifti images
header = spm_vol(path_to_image);
```

If the input image is a 4D nifti file, the structure `header` returned will have as many elements
as they are volumes in the file.

The fields of the structures are:

- `header.fname` - the filename of the image.
- `header.dim`   - the x, y and z dimensions of the volume
- `header.dt`    - A 1x2 array.  First element is datatype (see spm_type).
              The second is 1 or 0 depending on the endian-ness.
- `header.pinfo` - plane info for each plane of the volume.
  - `header.pinfo(1,:)` - scale for each plane
  - `header.pinfo((2,:)` - offset for each plane
                   The true voxel intensities of the jth image are given
                   by: `val*header.pinfo(1,j) + header.pinfo(2,j)`
  - `header.pinfo((3,:)` - offset into image (in bytes).
                   If the size of pinfo is 3x1, then the volume is assumed
                   to be contiguous and each plane has the same scalefactor
                   and offset.
- `header.mat`   - a 4x4 affine transformation matrix mapping from
              voxel coordinates to real world coordinates.
              This can also be directly accessed by `spm_get_space`.


### Voxel size

The voxel size are the 3 first values of the main diagonal of `header.mat`.
Get the value along the main diagonal of the matrix and stores it in a
temporary variable.

```matlab
temp = diag(header.mat);
```

Then we only keep the 3 first values of this diagonal to get the x, y, z dimension
of each voxel (in mm) of this image.

```matlab
% the "abs" is there to have the absolute value
VoxelsDimension = abs(temp(1:3));
```

### Getting the voxel subscripts of a given set of world space coordinates

```matlab
% world coordinate in mm
x = 0;
y = 0;
z = 0;
world_space_coordinates = [x; y; z; 1];

% Remember that if a matrix A performs a certain transformation,
% the matrix inv(A) will perform the reverse transformation
voxel_subscripts = inv(header.mat) * world_space_coordinates;

% we need to use 'round' to get a value that is not in between 2 voxels.
voxel_subscripts = round(voxel_subscripts(1:3));
```

### Getting the world space coordinate of a given voxel

```matlab
x = 1;
y = 1;
z = 1;

% We have to pad with an extra one to be able
% to multiply it with the transformation matrix.
voxel_subscripts = [x; y; z; 1];
world_space_coordinates = header.mat * voxel_subscripts;

% Only the three first value of this vector are of interest to us
world_space_coordinates = world_space_coordinates(1:3);
```
