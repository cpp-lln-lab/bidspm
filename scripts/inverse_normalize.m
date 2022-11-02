% (C) Copyright 2022 bidspm developers

this_dir = fullfile(fileparts(mfilename('fullpath')));

opt.dir.preproc = fullfile(this_dir, '..', ...
                           'demos', ...
                           'MoAE', ...
                           'outputs', ...
                           'derivatives', ...
                           'bidspm-preproc');

opt.verbosity = 3;

opt.bidsFilterFile.xfm.to = 'T1w';

opt.bidsFilterFile.roi.suffix = 'probseg';
opt.bidsFilterFile.roi.space = 'IXI549Space';
opt.bidsFilterFile.roi.label = 'CSF';
opt.bidsFilterFile.roi.modality = 'anat';

opt = checkOptions(opt);

matlabbatch = bidsInverseNormalize(opt);
