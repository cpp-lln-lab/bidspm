Links and references
********************

SPM starters
============

If you start from zero, go through the 2 first tutorials of SPM:

https://www.fil.ion.ucl.ac.uk/spm/data/


Andrew Jahn videos and blogs
============================

http://andysbrainblog.blogspot.com/search/label/marsbar

http://andysbrainblog.blogspot.com/search/label/SPM

http://andysbrainblog.blogspot.com/search/label/SPM.mat

https://www.youtube.com/watch?v=qbcBLXJhzZg&list=PLIQIswOrUH689KpRPCa5-h6U-m9CddWM6


SPM code snippets
=================

SPM wikibook has some very useful sections: https://en.wikibooks.org/wiki/SPM

From John Ashburner on Tom Nichols blog: https://blogs.warwick.ac.uk/nichols/tag/johns-gems/

From Rik Henson: http://www.mrc-cbu.cam.ac.uk/people/rik.henson/personal/analysis/

Some follow along tutorials written a long time ago,
and that probably should be turned into notebooks and updated.

Basic file / image manipulation with SPM: https://github.com/Remi-Gau/advanced_fMRI_course/blob/master/Practical%231/practical_1.m

HRF, convolution and GLM ("by hand"): https://github.com/Remi-Gau/advanced_fMRI_course/blob/master/Practical%232/practical_2.m

Design efficiency: https://github.com/Remi-Gau/advanced_fMRI_course/blob/master/Practical%233/practical_3.m


Content of SPM.mat
==================

This is here because SPM has the sad (and bad) Matlabic tradition of using variable names
that have often attempted to replicate the notation in the papers to make engineers
and the generally math enclined happy,
rather then the ``TypicalLongVariableNames`` that many programmers and new comers
would prefer to see to help with code readibility.

Adapted from: http://andysbrainblog.blogspot.com/2013/10/whats-in-spmmat-file.html


details on experiment
---------------------

- ``SPM.xY.RT``                - TR length (RT ="repeat time")
- ``SPM.xY.P``                 - matrix of file names
- ``SPM.xY.VY``                - (number of runs x 1) struct array of mapped image volumes (.nii file info)

- ``SPM.modality``             - the data you're using (PET, FMRI, EEG)

- ``SPM.stats.[modality].UFp`` - critical F-threshold for selecting voxels over which the non-sphericity is estimated (if required) [default: ``0.001``]
- ``SPM.stats.maxres``         - maximum number of residual images for smoothness estimation
- ``SPM.stats.maxmem``         - maximum amount of data processed at a time (in bytes)

- ``SPM.SPMid``                - version of SPM used

- ``SPM.swd``                  - directory for SPM.mat and nii files. default is ``pwd``


basis function
--------------

- ``SPM.xBF.name``     - name of basis function
- ``SPM.xBF.length``   - length in seconds of basis
- ``SPM.xBF.order``    - order of basis set
- ``SPM.xBF.T``        - number of subdivisions of TR
- ``SPM.xBF.T0``       - first time bin (see slice timing)
- ``SPM.xBF.UNITS``    - options: ``'scans'`` or ``'secs'`` for onsets
- ``SPM.xBF.Volterra`` - order of convolution
- ``SPM.xBF.dt``       - length of time bin in seconds
- ``SPM.xBF.bf``       - basis set matrix


Session structure
-----------------

Note that in SPM lingo sessions are equivalent to a runs in BIDS.

user-specified covariates/regressors
++++++++++++++++++++++++++++++++++++

e.g. motion

- ``SPM.Sess([sesssion]).C.C``    - (n x c) double regressor (``c`` is number of covariates, ``n`` is number of sessions)
- ``SPM.Sess([sesssion]).C.name`` - names of covariates

conditions & modulators specified
+++++++++++++++++++++++++++++++++

i.e. input structure array

- ``SPM.Sess([sesssion]).U(condition).dt``:  - time bin length (seconds)
- ``SPM.Sess([sesssion]).U(condition).name`` - names of conditions
- ``SPM.Sess([sesssion]).U(condition).ons``  - onset for condition's trials
- ``SPM.Sess([sesssion]).U(condition).dur``  - duration for condition's trials
- ``SPM.Sess([sesssion]).U(condition).u``    - (t x j) inputs or stimulus function matrix
- ``SPM.Sess([sesssion]).U(condition).pst``  - (1 x k) peri-stimulus times (seconds)

parameters/modulators specified
+++++++++++++++++++++++++++++++

- ``SPM.Sess([sesssion]).U(condition).P``      - parameter structure/matrix
- ``SPM.Sess([sesssion]).U(condition).P.name`` - names of modulators/parameters
- ``SPM.Sess([sesssion]).U(condition).P.h``    - polynomial order of modulating parameter (order of polynomial expansion where 0 is none)
- ``SPM.Sess([sesssion]).U(condition).P.P``    - vector of modulating values
- ``SPM.Sess([sesssion]).U(condition).P.P.i``  - sub-indices of ``U(i).u`` for plotting

scan indices for sessions
+++++++++++++++++++++++++

- ``SPM.Sess([sesssion]).row``

effect indices for sessions
+++++++++++++++++++++++++++

- ``SPM.Sess([sesssion]).col``

F Contrast information for input-specific effects
+++++++++++++++++++++++++++++++++++++++++++++++++

- ``SPM.Sess([sesssion]).Fc``
- ``SPM.Sess([sesssion]).Fc.i``    - F Contrast columns for input-specific effects
- ``SPM.Sess([sesssion]).Fc.name`` - F Contrast names for input-specific effects

- ``SPM.nscan([session])`` - number of scans per session (or if e.g. a t-test, total number of con*.nii files)


global variate/normalization details
------------------------------------

- ``SPM.xGX.iGXcalc`` - either ``'none'`` or ``'scaling'``

For fMRI usually is ``none`` (no global normalization).
If global normalization is ``scaling``, see ``spm_fmri_spm_ui`` for parameters that will then appear under ``SPM.xGX``.


design matrix information
-------------------------

- ``SPM.xX.X``        - design matrix (raw, not temporally smoothed)
- ``SPM.xX.name``     - cellstr of parameter names corresponding to columns of design matrix
- ``SPM.xX.I``        - (nScan x 4) matrix of factor level indicators. first column is the replication number.
                        Other columns are the levels of each experimental factor.
- ``SPM.xX.iH``       - vector of H partition (indicator variables) indices
- ``SPM.xX.iC``       - vector of C partition (covariates) indices
- ``SPM.xX.iB``       - vector of B partition (block effects) indices
- ``SPM.xX.iG``       - vector of G partition (nuisance variables) indices

- ``SPM.xX.K``        - cell. low frequency confound: high-pass cutoff (seconds)
- ``SPM.xX.K.HParam`` - low frequency cutoff value
- ``SPM.xX.K.X0``     - cosines (high-pass filter)

- ``SPM.xX.W``        - Optional whitening/weighting matrix used to give weighted least squares estimates (WLS).
  If not specified ``spm_spm`` will set this to whiten the data and render the OLS estimates maximum likelihood i.e. ``W*W' inv(xVi.V)``.

- ``SPM.xX.xKXs``     - space structure for K*W*X, the 'filtered and whitened' design matrix

  - ``SPM.xX.xKXs.X``   - matrix of trials and betas (columns) in each trial
  - ``SPM.xX.xKXs.tol`` - tolerance
  - ``SPM.xX.xKXs.ds``  - vectors of singular values
  - ``SPM.xX.xKXs.u``   - u as in X u*diag(ds)*v'
  - ``SPM.xX.xKXs.v``   - v as in X u*diag(ds)*v'
  - ``SPM.xX.xKXs.rk``  - rank
  - ``SPM.xX.xKXs.oP``  - orthogonal projector on X
  - ``SPM.xX.xKXs.oPp`` - orthogonal projector on X'
  - ``SPM.xX.xKXs.ups`` - space in which this one is embedded
  - ``SPM.xX.xKXs.sus`` - subspace

- ``SPM.xX.pKX``      - pseudoinverse of K*W*X, computed by ``spm_sp``
- ``SPM.xX.Bcov``     - xX.pKX*xX.V*xX.pKX - variance-covariance matrix of parameter estimates
                        (when multiplied by the voxel-specific hyperparameter ResMS of the parameter estimates (ResSS/xX.trRV ResMS) )
- ``SPM.xX.trRV``     - trace of R*V
- ``SPM.xX.trRVRV``   - trace of RVRV
- ``SPM.xX.erdf``     - effective residual degrees of freedom (``trRV^2/trRVRV``)
- ``SPM.xX.nKX``      - design matrix (``xX.xKXs.X``) scaled for display (see ``spm_DesMtx('sca',...`` for details)
- ``SPM.xX.sF``       - cellstr of factor names (columns in ``SPM.xX.I``, i think)
- ``SPM.xX.D``        - struct, design definition
- ``SPM.xX.xVi``      - correlation constraints (see non-sphericity below)

- ``SPM.xC``          - struct. array of covariate info


header info
-----------

- ``SPM.P`` - a matrix of filenames

- ``SPM.V`` - a vector of structures containing image volume information.

  - ``SPM.V.fname``      - the filename of the image.
  - ``SPM.V.dim``        - the x, y and z dimensions of the volume
  - ``SPM.V.dt``         - a (1 x 2) array. First element is datatype (see ``spm_type``). The second is 1 or 0 depending on the endian-ness.
  - ``SPM.V.mat``        - a (4 x 4) affine transformation matrix mapping from voxel coordinates to real world coordinates.
  - ``SPM.V.pinfo``      - plane info for each plane of the volume.
  - ``SPM.V.pinfo(1,:)`` - scale for each plane
  - ``SPM.V.pinfo(2,:)`` - offset for each plane The true voxel intensities of the j:sup:`th` image are given by: ``val*V.pinfo(1,j) + V.pinfo(2,j``)
  - ``SPM.V.pinfo(3,:)`` - offset into image (in bytes). If the size of pinfo is 3x1, then the volume is assumed to be contiguous and each plane has the same scale factor and offset.


structure describing intrinsic temporal non-sphericity
------------------------------------------------------

- ``SPM.xVi.I``   - typically the same as ``SPM.xX.I``
- ``SPM.xVi.h``   - hyperparameters
- ``SPM.xVi.V``    xVi.h(1)*xVi.Vi{1} + ...
- ``SPM.xVi.Cy``  - spatially whitened (used by ReML to estimate h)
- ``SPM.xVi.CY``  - ``<(Y - )*(Y - )'>`` (used by ``spm_spm_Bayes``)
- ``SPM.xVi.Vi``  - array of non-sphericity components

    - defaults to ``{speye(size(xX.X,1))}`` - i.i.d.
    - specifying a cell array of contraints ((Qi)
    - These contraints invoke ``spm_reml`` to estimate hyperparameters assuming V is constant over voxels that provide a high precise estimate of xX.V

- ``SPM.xVi.form`` - form of non-sphericity (either ``'none'`` or ``'AR(1)'`` or ``'FAST'``)

- ``SPM.xX.V``     - Optional non-sphericity matrix. ``CCov(e)sigma^2*V``.
  If not specified ``spm_spm`` will compute this using a 1st pass to identify signifcant voxels over which to estimate V.
  A 2nd pass is then used to re-estimate the parameters with WLS and save the ML estimates (unless xX.W is already specified).


filtering information
---------------------

- ``SPM.K`` - filter matrix or filtered structure

  - ``SPM.K(s)``        - struct array containing partition-specific specifications
  - ``SPM.K(s).RT``     - observation interval in seconds
  - ``SPM.K(s).row``    - row of Y constituting block/partitions
  - ``SPM.K(s).HParam`` - cut-off period in seconds
  - ``SPM.K(s).X0``     - low frequencies to be removed (DCT)

- ``SPM.Y`` - filtered data matrix


masking information
-------------------

- ``SPM.xM``     - Structure containing masking information, or a simple column vector of thresholds corresponding to the images in VY.
- ``SPM.xM.T``   - (n x 1) double - Masking index
- ``SPM.xM.TH``  - (nVar x nScan) matrix of analysis thresholds, one per image
- ``SPM.xM.I``   - Implicit masking (``0`` --> none; ``1`` --> implicit zero/NaN mask)
- ``SPM.xM.VM``  - struct array of mapped explicit mask image volumes
- ``SPM.xM.xs``  - (1 x 1) struct ; cellstr description


design information
------------------

self-explanatory names, for once

- ``SPM.xsDes.Basis_functions`` - type of basis function
- ``SPM.xsDes.Number_of_sessions``
- ``SPM.xsDes.Trials_per_session``
- ``SPM.xsDes.Interscan_interval``
- ``SPM.xsDes.High_pass_Filter``
- ``SPM.xsDes.Global_calculation``
- ``SPM.xsDes.Grand_mean_scaling``
- ``SPM.xsDes.Global_normalisation``


details on scanner data
-----------------------

e.g. smoothness

- ``SPM.xVol`` - structure containing details of volume analyzed

  - ``SPM.xVol.M``    - (4 x 4) voxel --> mm transformation matrix
  - ``SPM.xVol.iM``   - (4 x 4) mm --> voxel transformation matrix
  - ``SPM.xVol.DIM``  - image dimensions - column vector (in voxels)
  - ``SPM.xVol.XYZ``  - (3 x S) vector of in-mask voxel coordinates
  - ``SPM.xVol.S``    - Lebesgue measure or volume (in voxels)
  - ``SPM.xVol.R``    - vector of resel counts (in resels)
  - ``SPM.xVol.FWHM`` - Smoothness of components - FWHM, (in voxels)


info on beta files
------------------

- ``SPM.Vbeta`` - struct array of beta image handles

  - ``SPM.Vbeta.fname``   - beta nii file names
  - ``SPM.Vbeta.descrip`` - names for each beta file


info on variance of the error
-----------------------------

- ``SPM.VResMS`` - file struct of ResMS image handle

  - ``SPM.VResMS.fname`` - variance of error file name

info on mask
------------

- ``PM.VM`` - file struct of Mask image handle

  - ``PM.VM.fname`` - name of mask nii file


contrast details
----------------

added after running contrasts

- ``SPM.xCon`` - Contrast definitions structure array. See also ``spm_FcUtil.m`` for structure, rules & handling.

  - ``SPM.xCon.name`` - Contrast name
  - ``SPM.xCon.STAT`` - Statistic indicator character (``'T'``, ``'F'`` or ``'P'``)
  - ``SPM.xCon.c``    - Contrast weights (column vector contrasts)
  - ``SPM.xCon.X0``   - Reduced design matrix data (spans design space under Ho)

    - Stored as coordinates in the orthogonal basis of xX.X from spm_sp    (Matrix in SPM99b)
    - Extract using X0 ``spm_FcUtil('X0', ...``

  - ``SPM.xCon.iX0`` - Indicates how contrast was specified:

    - If by columns for reduced design matrix then iX0 contains the column indices.
    - Otherwise, it's a string containing the ``spm_FcUtil`` 'Set' action:
      Usually one of ``{'c','c+','X0'}`` defines the indices of the columns that will not be tested. Can be empty.

  - ``SPM.xCon.X1o`` - Remaining design space data (X1o is orthogonal to X0)

    - Stored as coordinates in the orthogonal basis of xX.X from ``spm_sp`` (Matrix in SPM99b)
    - Extract using X1o ``spm_FcUtil('X1o', ...``

  - ``SPM.xCon.eidf`` - Effective interest degrees of freedom (numerator df)

    - Or effect-size threshold for Posterior probability

  - ``SPM.xCon.Vcon`` - Name of contrast (for 'T's) or ESS (for 'F's) image
  - ``SPM.xCon.Vspm`` - Name of SPM image
