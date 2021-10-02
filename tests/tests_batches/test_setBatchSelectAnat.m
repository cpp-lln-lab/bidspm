% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSelectAnat %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSelectAnat_basic()

  % TODO
  % add test to check if anat is not in first session
  % add test to check if anat is not a T1w

  subLabel = '01';

  opt = setOptions('MoAE', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.raw);

  matlabbatch = {};
  matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

  expectedBatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';

  anatFile = spm_select('FPlist', ...
                        fullfile( ...
                                 opt.dir.raw, ...
                                 'sub-01', ...
                                 'anat'), ...
                        '^sub-01_T1w.nii$');
  expectedBatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

  assertEqual(matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}, ...
              expectedBatch{1}.cfg_basicio.cfg_named_file.files{1});

end
