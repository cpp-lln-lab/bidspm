function test_suite = test_bidsModelSelection %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_bidsModelSelection_basic()

  createDummyData();

  % GIVEN
  opt = setOptions('vislocalizer');
  opt = rmfield(opt, 'taskName');
  opt.toolbox.MACS.model.files = {fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizer_smdl.json')
                                  fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizerGlobalSignal_smdl.json')};

  % WHEN
  matlabbatch = bidsModelSelection(opt);

  % THEN
  expectedContent = {'vislocalizer'; 'global signal'};
  assertEqual(matlabbatch{1}.spm.tools.MACS.MA_model_space.names, expectedContent);

  nbSubjects = 3;
  assertEqual(size(matlabbatch{1}.spm.tools.MACS.MA_model_space.models, 2), nbSubjects);

  nbModels = 2;
  assertEqual(size(matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1}, 2), nbModels);

  cleanUp();

end

function test_bidsModelSelection_error_no_model_list()
  opt = setOptions('vislocalizer');
  assertExceptionThrown(@()bidsModelSelection(opt), ...
                        'bidsModelSelection:noModelList');
end

function test_bidsModelSelection_different_missing_model_file()

  % GIVEN
  opt = setOptions('vislocalizer');
  opt = rmfield(opt, 'taskName');
  opt.toolbox.MACS.model.files = {fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizer_smdl.json')
                                  fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-notHere_smdl.json')};

  % WHEN
  assertExceptionThrown(@()bidsModelSelection(opt), ...
                        'bidsModelSelection:noModelFile');

end

function test_bidsModelSelection_different_tasks_1()

  % GIVEN
  opt = setOptions('vislocalizer');
  opt = rmfield(opt, 'taskName');
  opt.toolbox.MACS.model.files = {fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizer_smdl.json')
                                  fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vismotion_smdl.json')};

  % WHEN
  assertExceptionThrown(@()bidsModelSelection(opt), ...
                        'bidsModelSelection:differentModelTasks');

end

function test_bidsModelSelection_different_tasks_2()

  % GIVEN
  opt = setOptions('vislocalizer');
  opt = rmfield(opt, 'taskName');
  opt.toolbox.MACS.model.files = {fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizer_smdl.json')
                                  fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vismotionvislocalizer_smdl.json')};

  % WHEN
  assertExceptionThrown(@()bidsModelSelection(opt), ...
                        'bidsModelSelection:differentModelTasks');

end

function test_bidsModelSelection_missing_space()

  % GIVEN
  opt = setOptions('vislocalizer');
  opt = rmfield(opt, 'taskName');
  opt.toolbox.MACS.model.files = {fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-vislocalizer_smdl.json')
                                  fullfile(getDummyDataDir(), ...
                                           'models', ...
                                           'model-default_smdl.json')};

  % WHEN
  assertExceptionThrown(@()bidsModelSelection(opt), ...
                        'bidsModelSelection:missingModelInputSpace');

end

function setUp()

end

function cleanUp()

end
