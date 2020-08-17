function test_modelFiles()
    % vague attempt at validating our model files

    %%
    file = fullfile(fileparts(mfilename), '..', 'demo', 'model-MoAE_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', 'model-visMotionLoc_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', 'model-motionDecodingUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', 'model-motionDecodingMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', 'model', 'model-balloonanalogriskUnivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

    %%
    file = fullfile(fileparts(mfilename), '..', 'model', 'model-balloonanalogriskMultivariate_smdl.json');

    model = spm_jsonread(file);

    model.Steps{1};

end
