% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_modelFiles %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_modelFilesBasic()
  % vague attempt at validating our model files

  demoDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos');

  %%
  file = fullfile(demoDir, 'MoAE', 'models', 'model-MoAE_smdl.json');

  model = spm_jsonread(file);

  model.Steps{1};

  %%
  file = fullfile(demoDir, 'vismotion', 'models', ...
                  'model-visMotionLoc_smdl.json');

  model = spm_jsonread(file);

  model.Steps{1};

  %%
  file = fullfile(demoDir, 'vismotion', 'models', ...
                  'model-motionDecodingUnivariate_smdl.json');

  model = spm_jsonread(file);

  model.Steps{1};

  %%
  file = fullfile(demoDir, 'vismotion', 'models', ...
                  'model-motionDecodingMultivariate_smdl.json');

  model = spm_jsonread(file);

  model.Steps{1};

end
