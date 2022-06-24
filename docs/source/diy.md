# Do it yourself

Listing here some basic commands you might need to know to combine masks by
hand.

Also good way to learn about some basic low level functions of SPM.

-   `spm_vol`: reads the header of a 3D or 4D Nifti images
-   `spm_read_vols`: given a header it will get the data of Nifti image
-   `spm_write_vol`: given a header it will get the data of Nifti image

For more info about basic files, check the
[SPM wikibooks](https://en.wikibooks.org/wiki/SPM/Programming_intro#SPM_functions).

## Merging 2 masks

```matlab
path_to_mask_1 = 'FIX_ME';
path_to_mask_2 = 'FIX_ME';

% get header of Nifti images
header_1 = spm_vol(path_to_mask_1);
header_2 = spm_vol(path_to_mask_2);

% if you want to make sure that images are in the same space
% and have same resolution
masks = char({path_to_mask_1; path_to_mask_2});
spm_check_orientations(spm_vol(masks));

% get data of Nifti images
mask_1 = spm_read_vols(header_1);
mask_2 = spm_read_vols(header_2);

% concatenate data along the 4th dimension
merged_mask = cat(4, mask_1, mask_2);

% keep any voxel that has some value along the 4th dimension
merged_mask = any(merged_mask, 4);

% create a new header of the final mask
merged_mask_header = header_1;
merged_mask_header.fname = 'new_mask.nii';

spm_write_vol(merged_mask_header, merged_mask);
```
