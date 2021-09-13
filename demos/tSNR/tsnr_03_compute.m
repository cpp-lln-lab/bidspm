% (C) Copyright 2019 Remi Gau

clear;

opt = tsnr_get_option();

opt = checkOptions(opt);

[BIDS, opt] = getData(opt, opt.dir.preproc);

opt.dir.roi = fullfile(opt.dir.preproc, '..', 'cpp_spm-roi');
opt = rmfield(opt, 'taskName');
[BIDSroi, opt] = getData(opt, opt.dir.roi);

% TODO ideally loop over subjects

boldImage = bids.query(BIDS, 'data', 'sub', 'CTL05', 'suffix', 'bold', 'desc', 'preproc');
referenceImg = bids.query(BIDS, 'data', 'sub', 'CTL05', 'suffix', 'bold', 'desc', 'mean');
roi =  bids.query(BIDSroi, 'data', 'sub', 'CTL05');

% TODO reslice for each acquisition resolution

matlabbatch = {};
matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, roi);
spm_jobman('run', matlabbatch);

opt.dir.preproc = opt.dir.roi;
opt.query.modality = 'roi';
opt = set_spm_2_bids_defaults(opt);
name_spec.entities = struct('acq', 'xxx');
opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', 'r', ...
                                            'name_spec', name_spec);
opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();

bidsRename(opt);

[tsnrImage, volTsnr] = computeTsnr(boldImage);

[BIDSroi, opt] = getData(opt, opt.dir.roi);
roi =  bids.query(BIDSroi, 'data', 'sub', 'CTL05', 'acq', 'xxx');

% TODO loop over ROIs
value = computeMeanValueInMask(tsnrImage, roi{1});
