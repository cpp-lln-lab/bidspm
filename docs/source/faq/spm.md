<!-- the section below is automatically generated.

If you want to modify the questions:
- please edit the files in the `faq` folder in the doc

-->

# SPM

## How can get the data from some specific voxel in a nifti image?

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

## How can I use SPM image calculator (`imcalc`) to create a ROI?

The image calculator utility is accessible in the SPM batch GUI:

`Batch --> SPM --> Util --> Image Calculator`

You can select the input image you want to use to create a ROI (like an atlas
for example), and then set the expression you want to use to only keep certain
voxels as part of the binary mask that will define your ROI.

If you want to keep voxels for your ROI that have a value of 51 or 52 or 53, you
would use the following expression:

```matlab
i1==51 || i1==52 || i1 == 53
```

If you save the batch and its job you will get an .m file that may contain
something like this.

```matlab
matlabbatch{1}.spm.util.imcalc.input = fullpath_to_the_image;
matlabbatch{1}.spm.util.imcalc.output = 'output';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1==51 || i1==52 || i1 == 53';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
```

## How can set the value of a specific voxel in a nifti image?

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

## How do I get the header of a nifti image?

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

## How do I know which matlab function performs a given SPM process?

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

## How do I merge 2 masks with SPM?

Here is a code snippet to merge 2 masks:

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

Also good way to learn about some basic low level functions of SPM.

-   `spm_vol`: reads the header of a 3D or 4D Nifti images
-   `spm_read_vols`: given a header it will get the data of Nifti image
-   `spm_write_vol`: given a header and a 3D matrix, it will write a Nifti image

For more info about basic files, check the
[SPM wikibooks](https://en.wikibooks.org/wiki/SPM/Programming_intro#SPM_functions).

## What is the content of the SPM.mat file?

This is here because SPM has the sad (and bad) Matlabic tradition of using variable names
that have often attempted to replicate the notation in the papers to make engineers
and the generally math enclined happy,
rather than the `TypicalLongVariableNames` that many programmers and new comers
would prefer to see to help with code readability.

Adapted from: http://andysbrainblog.blogspot.com/2013/10/whats-in-spmmat-file.html


### details on experiment


- `SPM.xY.RT`                - TR length (RT ="repeat time")
- `SPM.xY.P`                 - matrix of file names
- `SPM.xY.VY`                - (number of runs x 1) struct array of mapped image volumes (.nii file info)

- `SPM.modality`             - the data you're using (PET, FMRI, EEG)

- `SPM.stats.[modality].UFp` - critical F-threshold for selecting voxels over which the non-sphericity is estimated
                               (if required) [default: `0.001`]
- `SPM.stats.maxres`         - maximum number of residual images for smoothness estimation
- `SPM.stats.maxmem`         - maximum amount of data processed at a time (in bytes)

- `SPM.SPMid`                - version of SPM used

- `SPM.swd`                  - directory for SPM.mat and nii files. default is `pwd`


###  basis function


- `SPM.xBF.name`     - name of basis function
- `SPM.xBF.length`   - length in seconds of basis
- `SPM.xBF.order`    - order of basis set
- `SPM.xBF.T`        - number of subdivisions of TR
- `SPM.xBF.T0`       - first time bin (see slice timing)
- `SPM.xBF.UNITS`    - options: `'scans'` or `'secs'` for onsets
- `SPM.xBF.Volterra` - order of convolution
- `SPM.xBF.dt`       - length of time bin in seconds
- `SPM.xBF.bf`       - basis set matrix


### Session structure


Note that in SPM lingo sessions are equivalent to a runs in BIDS.

#### user-specified covariates/regressors


e.g. motion

- `SPM.Sess([session]).C.C`    - (n x c) double regressor (`c` is number of covariates, `n` is number of sessions)
- `SPM.Sess([session]).C.name` - names of covariates

#### conditions & modulators specified


i.e. input structure array

- `SPM.Sess([session]).U(condition).dt`:  - time bin length (seconds)
- `SPM.Sess([session]).U(condition).name` - names of conditions
- `SPM.Sess([session]).U(condition).ons`  - onset for condition's trials
- `SPM.Sess([session]).U(condition).dur`  - duration for condition's trials
- `SPM.Sess([session]).U(condition).u`    - (t x j) inputs or stimulus function matrix
- `SPM.Sess([session]).U(condition).pst`  - (1 x k) peri-stimulus times (seconds)

#### parameters/modulators specified


- `SPM.Sess([session]).U(condition).P`      - parameter structure/matrix
- `SPM.Sess([session]).U(condition).P.name` - names of modulators/parameters
- `SPM.Sess([session]).U(condition).P.h`    - polynomial order of modulating parameter (order of polynomial expansion where 0 is none)
- `SPM.Sess([session]).U(condition).P.P`    - vector of modulating values
- `SPM.Sess([session]).U(condition).P.P.i`  - sub-indices of `U(i).u` for plotting

#### scan indices for sessions


- `SPM.Sess([session]).row`

#### effect indices for sessions


- `SPM.Sess([session]).col`

#### F Contrast information for input-specific effects


- `SPM.Sess([session]).Fc`
- `SPM.Sess([session]).Fc.i`    - F Contrast columns for input-specific effects
- `SPM.Sess([session]).Fc.name` - F Contrast names for input-specific effects

- `SPM.nscan([session])` - number of scans per session (or if e.g. a t-test, total number of con*.nii files)


### global variate/normalization details


- `SPM.xGX.iGXcalc` - either `'none'` or `'scaling'`

For fMRI usually is `none` (no global normalization).
If global normalization is `scaling`, see `spm_fmri_spm_ui` for parameters that will then appear under `SPM.xGX`.


### design matrix information


- `SPM.xX.X`        - design matrix (raw, not temporally smoothed)
- `SPM.xX.name`     - cellstr of parameter names corresponding to columns of design matrix
- `SPM.xX.I`        - (nScan x 4) matrix of factor level indicators. first column is the replication number.
                      Other columns are the levels of each experimental factor.
- `SPM.xX.iH`       - vector of H partition (indicator variables) indices
- `SPM.xX.iC`       - vector of C partition (covariates) indices
- `SPM.xX.iB`       - vector of B partition (block effects) indices
- `SPM.xX.iG`       - vector of G partition (nuisance variables) indices

- `SPM.xX.K`        - cell. low frequency confound: high-pass cutoff (seconds)
- `SPM.xX.K.HParam` - low frequency cutoff value
- `SPM.xX.K.X0`     - cosines (high-pass filter)

- `SPM.xX.W`        - Optional whitening/weighting matrix used to give weighted least squares estimates (WLS).
                      If not specified `spm_spm` will set this to whiten the data
                      and render the OLS estimates maximum likelihood i.e. `W*W' inv(xVi.V)`.

- `SPM.xX.xKXs`     - space structure for K*W*X, the 'filtered and whitened' design matrix

  - `SPM.xX.xKXs.X`   - matrix of trials and betas (columns) in each trial
  - `SPM.xX.xKXs.tol` - tolerance
  - `SPM.xX.xKXs.ds`  - vectors of singular values
  - `SPM.xX.xKXs.u`   - u as in X u*diag(ds)*v'
  - `SPM.xX.xKXs.v`   - v as in X u*diag(ds)*v'
  - `SPM.xX.xKXs.rk`  - rank
  - `SPM.xX.xKXs.oP`  - orthogonal projector on X
  - `SPM.xX.xKXs.oPp` - orthogonal projector on X'
  - `SPM.xX.xKXs.ups` - space in which this one is embedded
  - `SPM.xX.xKXs.sus` - subspace

- `SPM.xX.pKX`      - pseudoinverse of K*W*X, computed by `spm_sp`
- `SPM.xX.Bcov`     - xX.pKX*xX.V*xX.pKX - variance-covariance matrix of parameter estimates
                      (when multiplied by the voxel-specific hyperparameter ResMS of the parameter estimates (ResSS/xX.trRV ResMS) )
- `SPM.xX.trRV`     - trace of R*V
- `SPM.xX.trRVRV`   - trace of RVRV
- `SPM.xX.erdf`     - effective residual degrees of freedom (`trRV^2/trRVRV`)
- `SPM.xX.nKX`      - design matrix (`xX.xKXs.X`) scaled for display (see `spm_DesMtx('sca',...` for details)
- `SPM.xX.sF`       - cellstr of factor names (columns in `SPM.xX.I`, i think)
- `SPM.xX.D`        - struct, design definition
- `SPM.xX.xVi`      - correlation constraints (see non-sphericity below)

- `SPM.xC`          - struct. array of covariate info


### header info


- `SPM.P` - a matrix of filenames

- `SPM.V` - a vector of structures containing image volume information.

  - `SPM.V.fname`      - the filename of the image.
  - `SPM.V.dim`        - the x, y and z dimensions of the volume
  - `SPM.V.dt`         - a (1 x 2) array. First element is datatype (see `spm_type`).
                         The second is 1 or 0 depending on the endian-ness.
  - `SPM.V.mat`        - a (4 x 4) affine transformation matrix mapping from voxel coordinates
                         to real world coordinates.
  - `SPM.V.pinfo`      - plane info for each plane of the volume.
  - `SPM.V.pinfo(1,:)` - scale for each plane
  - `SPM.V.pinfo(2,:)` - offset for each plane The true voxel intensities of the j<sup>`th`</sup> image are given by: `val*V.pinfo(1,j) + V.pinfo(2,j`)
  - `SPM.V.pinfo(3,:)` - offset into image (in bytes). If the size of pinfo is 3x1,
                         then the volume is assumed to be contiguous and each plane has the same scale factor and offset.


### structure describing intrinsic temporal non-sphericity


- `SPM.xVi.I`   - typically the same as `SPM.xX.I`
- `SPM.xVi.h`   - hyperparameters
- `SPM.xVi.V`   - xVi.h(1)*xVi.Vi{1} + ...
- `SPM.xVi.Cy`  - spatially whitened (used by ReML to estimate h)
- `SPM.xVi.CY`  - `<(Y - )*(Y - )'>` (used by `spm_spm_Bayes`)
- `SPM.xVi.Vi`  - array of non-sphericity components

    - defaults to `{speye(size(xX.X,1))}` - i.i.d.
    - specifying a cell array of constraints ((Qi)
    - These constraints invoke `spm_reml` to estimate hyperparameters assuming V is constant over voxels that provide a high precise estimate of xX.V

- `SPM.xVi.form` - form of non-sphericity (either `'none'` or `'AR(1)'` or `'FAST'`)

- `SPM.xX.V`     - Optional non-sphericity matrix. `CCov(e)sigma^2*V`.
  If not specified `spm_spm` will compute this using a 1st pass to identify significant voxels over which to estimate V.
  A 2nd pass is then used to re-estimate the parameters with WLS and save the ML estimates (unless xX.W is already specified).


### filtering information


- `SPM.K` - filter matrix or filtered structure

  - `SPM.K(s)`        - structure array containing partition-specific specifications
  - `SPM.K(s).RT`     - observation interval in seconds
  - `SPM.K(s).row`    - row of Y constituting block/partitions
  - `SPM.K(s).HParam` - cut-off period in seconds
  - `SPM.K(s).X0`     - low frequencies to be removed (DCT)

- `SPM.Y` - filtered data matrix


### masking information


- `SPM.xM`     - Structure containing masking information, or a simple column vector of thresholds corresponding to the images in VY.
- `SPM.xM.T`   - (n x 1) double - Masking index
- `SPM.xM.TH`  - (nVar x nScan) matrix of analysis thresholds, one per image
- `SPM.xM.I`   - Implicit masking (`0` --> none; `1` --> implicit zero/NaN mask)
- `SPM.xM.VM`  - struct array of mapped explicit mask image volumes
- `SPM.xM.xs`  - (1 x 1) struct ; cellstr description


### design information


self-explanatory names, for once

- `SPM.xsDes.Basis_functions` - type of basis function
- `SPM.xsDes.Number_of_sessions`
- `SPM.xsDes.Trials_per_session`
- `SPM.xsDes.Interscan_interval`
- `SPM.xsDes.High_pass_Filter`
- `SPM.xsDes.Global_calculation`
- `SPM.xsDes.Grand_mean_scaling`
- `SPM.xsDes.Global_normalisation`


### details on scanner data


e.g. smoothness

- `SPM.xVol` - structure containing details of volume analyzed

  - `SPM.xVol.M`    - (4 x 4) voxel --> mm transformation matrix
  - `SPM.xVol.iM`   - (4 x 4) mm --> voxel transformation matrix
  - `SPM.xVol.DIM`  - image dimensions - column vector (in voxels)
  - `SPM.xVol.XYZ`  - (3 x S) vector of in-mask voxel coordinates
  - `SPM.xVol.S`    - Lebesgue measure or volume (in voxels)
  - `SPM.xVol.R`    - vector of resel counts (in resels)
  - `SPM.xVol.FWHM` - Smoothness of components - FWHM, (in voxels)


### info on beta files


- `SPM.Vbeta` - struct array of beta image handles

  - `SPM.Vbeta.fname`   - beta nii file names
  - `SPM.Vbeta.descrip` - names for each beta file


### info on variance of the error

- `SPM.VResMS` - file struct of ResMS image handle

  - `SPM.VResMS.fname` - variance of error file name

### info on mask


- `SPM.VM` - file struct of Mask image handle

  - `SPM.VM.fname` - name of mask nii file


### contrast details


added after running contrasts

- `SPM.xCon` - Contrast definitions structure array. See also `spm_FcUtil.m` for structure, rules & handling.

  - `SPM.xCon.name` - Contrast name
  - `SPM.xCon.STAT` - Statistic indicator character (`'T'`, `'F'` or `'P'`)
  - `SPM.xCon.c`    - Contrast weights (column vector contrasts)
  - `SPM.xCon.X0`   - Reduced design matrix data (spans design space under Ho)

    - Stored as coordinates in the orthogonal basis of xX.X from spm_sp    (Matrix in SPM99b)
    - Extract using X0 `spm_FcUtil('X0', ...`

  - `SPM.xCon.iX0` - Indicates how contrast was specified:

    - If by columns for reduced design matrix then iX0 contains the column indices.
    - Otherwise, it's a string containing the `spm_FcUtil` 'Set' action:
      Usually one of `{'c','c+','X0'}` defines the indices of the columns that will not be tested. Can be empty.

  - `SPM.xCon.X1o` - Remaining design space data (X1o is orthogonal to X0)

    - Stored as coordinates in the orthogonal basis of xX.X from `spm_sp` (Matrix in SPM99b)
    - Extract using X1o `spm_FcUtil('X1o', ...`

  - `SPM.xCon.eidf` - Effective interest degrees of freedom (numerator df)

    - Or effect-size threshold for Posterior probability

  - `SPM.xCon.Vcon` - Name of contrast (for 'T's) or ESS (for 'F's) image
  - `SPM.xCon.Vspm` - Name of SPM image

---

Generated by [FAQtory](https://github.com/willmcgugan/faqtory)
