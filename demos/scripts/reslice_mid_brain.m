% Relice midbrain masks at the correct resolution
%

% (C) Copyright 2021 bidspm developers

opt.dir.input = opt.dir.preproc;

[BIDS, opt] = setUpWorkflow(opt, 'Midbrain Reslice');

use_schema = false;
BIDSroi =  bids.layout(opt.dir.roi, use_schema);

for iSub = 1:numel(opt.subjects)

  subLabel = opt.subjects{iSub};

  roiFiles = bids.query(BIDSroi, 'data', 'sub', subLabel, 'label', 'V1d', 'hemi', 'R');

  referenceImg = bids.query(BIDS, 'data', 'space', 'individual', 'desc', 'mean', 'suffix', 'bold');

  printProcessingSubject(iSub, subLabel);

  matlabbatch = {};

  matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, roiFiles, interp);

  saveAndRunWorkflow(matlabbatch, 'Midbrain Reslice', opt, subLabel);

end

cleanUpWorkflow(opt);

bidsRename(opt);
