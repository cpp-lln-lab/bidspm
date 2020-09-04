function test_suite = test_modelFiles %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_modelFilesBasic()
    % vague attempt at validating our model files

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'demo', 'model-MoAE_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'model-visMotionLoc_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'model-motionDecodingUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'model-motionDecodingMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'model', 'model-balloonanalogriskUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', ...
        'model', 'model-balloonanalogriskMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

end
