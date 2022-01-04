% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_setBatchLesionSegmentation %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchLesionSegmentation_basic()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'useRaw', true);

  if not(isfield(opt.toolbox, 'ALI'))
    return
  end

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  matlabbatch = {};
  matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel);

  unified_segmentation.step1data{1} = fullfile(getDummyDataDir('raw'), ...
                                               ['sub-' subLabel], ...
                                               'ses-01', 'anat', ...
                                               'sub-01_ses-01_T1w.nii');
  unified_segmentation.step1prior = {fullfile(spm('dir'), ...
                                              'toolbox', 'ALI', ...
                                              'Priors_extraClass', ...
                                              'wc4prior0.nii')};
  unified_segmentation.step1niti = 2;
  unified_segmentation.step1thr_prob = 0.3330;
  unified_segmentation.step1thr_size = 0.8000;
  unified_segmentation.step1coregister = 1;
  unified_segmentation.step1mask = {''};
  unified_segmentation.step1vox = 2;
  unified_segmentation.step1fwhm = [8 8 8];

  expectedbatch{1}.spm.tools.ali.unified_segmentation = unified_segmentation;

  assertEqual(matlabbatch{1}.spm.tools.ali.unified_segmentation, ...
              expectedbatch{1}.spm.tools.ali.unified_segmentation);

end
