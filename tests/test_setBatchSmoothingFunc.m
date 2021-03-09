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
  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  % create dummy normalized file
  fileName = spm_BIDS(BIDS, 'data', ...
                      'sub', subLabel, ...
                      'task', opt.taskName, ...
                      'type', 'bold');
  [filepath, filename, ext] = fileparts(fileName{1});
  fileName = fullfile( ...
                      filepath, ...
                      [spm_get_defaults('normalise.write.prefix'), ...
                       spm_get_defaults('unwarp.write.prefix'), ...
                       filename ext]);
  system(sprintf('touch %s', fileName));

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
