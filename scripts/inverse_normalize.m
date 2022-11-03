% (C) Copyright 2022 bidspm developers

this_dir = fullfile(fileparts(mfilename('fullpath')));

% we are using the output data from the MoAE demo
% so make sure you have run it before trying this.
opt.dir.preproc = fullfile(this_dir, '..', ...
                           'demos', ...
                           'MoAE', ...
                           'outputs', ...
                           'derivatives', ...
                           'bidspm-preproc');

opt.verbosity = 3;

% xfm are the images containing the deformation fields of SPM
% here we specify that we want to use the deformation field
% to transform images to T1w native space
opt.bidsFilterFile.xfm.to = 'T1w';

% here we use the 'roi' field of bidsFilterFile to specify the filter
% we want to use to select the images we want to normalise.
% here we will select the CSF tissue probability map to inverse normalize
% it to native space
opt.bidsFilterFile.roi.suffix = 'probseg';
opt.bidsFilterFile.roi.space = 'IXI549Space';
opt.bidsFilterFile.roi.label = 'CSF';
opt.bidsFilterFile.roi.modality = 'anat';

opt = checkOptions(opt);

matlabbatch = bidsInverseNormalize(opt);
