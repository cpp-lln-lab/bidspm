% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSmoothingFunc %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSmoothingFuncBasic()

  % TODO
  % need a test with several sessions and runs

  subLabel = '01';

  funcFWHM = 6;

  opt = setOptions('MoAE', subLabel);
  opt.space = {'MNI'};

  [BIDS, opt] = getData(opt, opt.dir.raw);

  % create dummy normalized file
  fileName = bids.query(BIDS, 'data', ...
                        'sub', subLabel, ...
                        'task', opt.taskName, ...
                        'suffix', 'bold');

  [filepath, filename, ext] = fileparts(fileName{1});

  p =  bids.internal.parse_filename([filename ext]);
  p.entities.space = 'IXI549Space';
  p.entities.desc = 'preproc';
  p.use_schema = false;
  fileName = bids.create_filename(p);

  system(sprintf('touch %s', fullfile(filepath, fileName)));

  matlabbatch = [];
  matlabbatch = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel, funcFWHM);

  expectedBatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
  expectedBatch{1}.spm.spatial.smooth.dtype = 0;
  expectedBatch{1}.spm.spatial.smooth.im = 0;
  expectedBatch{1}.spm.spatial.smooth.prefix = ...
      [spm_get_defaults('smooth.prefix'), '6'];
  expectedBatch{1}.spm.spatial.smooth.data{1} = fileName;

  assertEqual(matlabbatch, expectedBatch);

end
