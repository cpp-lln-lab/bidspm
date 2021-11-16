% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_createDataDictionary %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% silence until functional QA has been updated to take BIDS as input

function test_createDataDictionary_basic()

  subLabel = '01';
  iSes = 1;
  iRun = 1;
  %
  %   opt = setOptions('vislocalizer', subLabel);
  %
  %   [BIDS, opt] = getData(opt, opt.dir.preproc);
  %
  %   opt.query = struct('acq', '');
  %
  %   sessions = getInfo(BIDS, subLabel, opt, 'Sessions');
  %
  %   runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});
  %
  %   [fileName, subFuncDataDir] = getBoldFilename( ...
  %                                                BIDS, ...
  %                                                subLabel, sessions{iSes}, runs{iRun}, opt);
  %
  %   createDataDictionary(subFuncDataDir, fileName, 3);
  %
  %   expectedFileName = fullfile( ...
  %                               subFuncDataDir, ...
  %                               'sub-01_ses-01_task-vislocalizer_desc-confounds_regressors.json');
  %
  %   content = spm_jsonread(expectedFileName);
  %
  %   expectedNbColumns = 27;
  %   expectedHeaderCol = 'censoring_regressor_3';
  %
  %   assertEqual(numel(content.Columns), expectedNbColumns);
  %   assertEqual(content.Columns{expectedNbColumns}, 'censoring_regressor_3');
  %
end
