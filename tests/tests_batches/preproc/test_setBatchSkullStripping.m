% (C) Copyright 2019 bidspm developers

function test_suite = test_setBatchSkullStripping %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSkullStripping_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  opt.orderBatches.segment = 2;

  matlabbatch = {};
  matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

  expectedBatch = returnExpectedBatch(opt);

  assertEqual(matlabbatch{1}.spm.util.imcalc, expectedBatch{1}.spm.util.imcalc);
  assertEqual(matlabbatch{end}.spm.util.imcalc, expectedBatch{end}.spm.util.imcalc);

  assertEqual(exist(fullfile(BIDS.pth, 'desc-skullstripped.json'), 'file'), 2);
  delete(fullfile(BIDS.pth, 'desc-skullstripped.json'));

  assertEqual(exist(fullfile(BIDS.pth, 'sub-01', 'ses-01', 'anat', ...
                             'sub-01_ses-01_space-individual_desc-skullstripped_T1w.json'), ...
                    'file'), 2);
  delete(fullfile(BIDS.pth, 'sub-01', 'ses-01', 'anat', ...
                  'sub-01_ses-01_space-individual_desc-skullstripped_T1w.json'));

  assertEqual(exist(fullfile(BIDS.pth, 'sub-01', 'ses-01', 'anat', ...
                             'sub-01_ses-01_space-individual_desc-brain_mask.json'), ...
                    'file'), 2);
  delete(fullfile(BIDS.pth, 'sub-01', 'ses-01', 'anat', ...
                  'sub-01_ses-01_space-individual_desc-brain_mask.json'));

end

function test_setBatchSkullStripping_without_segment

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  matlabbatch = {};
  matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

  assertEqual(numel(matlabbatch{1}.spm.util.imcalc.input{1}), 1);

end

function test_setBatchSkullStripping_skip_skullstrip()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.skullstrip.do = false;

  BIDS = struct([]);

  matlabbatch = {};
  matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

  assert(isempty(matlabbatch));

end

function expectedBatch = returnExpectedBatch(opt)

  expectedAnatDataDir = fullfile(getTestDataDir('preproc'), 'sub-01', 'ses-01', 'anat');

  expectedBatch = [];

  imcalc.input(1) = cfg_dep('Segment: Bias Corrected (1)', ...
                            substruct('.', 'val', '{}', {2}, ...
                                      '.', 'val', '{}', {1}, ...
                                      '.', 'val', '{}', {1}), ...
                            substruct('.', 'channel', '()', {1}, ...
                                      '.', 'biascorr', '()', {':'}));

  imcalc.input(2) = cfg_dep('Segment: c1 Images', ...
                            substruct('.', 'val', '{}', {2}, ...
                                      '.', 'val', '{}', {1}, ...
                                      '.', 'val', '{}', {1}), ...
                            substruct('.', 'tiss', '()', {1}, ...
                                      '.', 'c', '()', {':'}));

  imcalc.input(3) = cfg_dep('Segment: c2 Images', ...
                            substruct('.', 'val', '{}', {2}, ...
                                      '.', 'val', '{}', {1}, ...
                                      '.', 'val', '{}', {1}), ...
                            substruct('.', 'tiss', '()', {2}, ...
                                      '.', 'c', '()', {':'}));
  imcalc.input(4) = cfg_dep('Segment: c3 Images', ...
                            substruct('.', 'val', '{}', {2}, ...
                                      '.', 'val', '{}', {1}, ...
                                      '.', 'val', '{}', {1}), ...
                            substruct('.', 'tiss', '()', {3}, ...
                                      '.', 'c', '()', {':'}));

  imcalc.output = 'sub-01_ses-01_space-individual_desc-skullstripped_T1w.nii';
  imcalc.outdir = {expectedAnatDataDir};
  imcalc.expression = sprintf('i1.*((i2+i3+i4)>%f)', opt.skullstrip.threshold);
  imcalc.options.dtype = 16;

  expectedBatch = {};
  expectedBatch{end + 1}.spm.util.imcalc = imcalc;

  % add a batch to output the mask
  imcalc.expression = sprintf('(i2+i3+i4)>%f', opt.skullstrip.threshold);
  imcalc.output = 'sub-01_ses-01_space-individual_desc-brain_mask.nii';

  expectedBatch{end + 1}.spm.util.imcalc = imcalc;

end
