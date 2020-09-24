function test_suite = test_modelFiles %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_modelFilesBasic()
    % vague attempt at validating our model files

    demoDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demo');
    modelDir = fullfile(fileparts(mfilename('fullpath')), '..', 'model');

    %%
    file = fullfile(demoDir, 'model-MoAE_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename('fullpath')), '..', ...
                    'model-visMotionLoc_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename('fullpath')), '..', ...
                    'model-motionDecodingUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename('fullpath')), '..', ...
                    'model-motionDecodingMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(modelDir, 'model-balloonanalogriskUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(modelDir, 'model-balloonanalogriskMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

end
