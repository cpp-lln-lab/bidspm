% Example of how to use transformers to:
%
% - "merge" certain trial type by renaming them using the Replace transformer
% - "split" the trials of certain conditions
%
% For MVPA analyses, this can be used to have 1 beta per trial (and not 1 per run per condition).
%
% (C) Copyright 2021 Remi Gau

tsvFile = fullfile(pwd, 'data', 'sub-03_task-VisuoTact_run-02_events.tsv');

opt.model.file = fullfile(pwd, 'models', 'model-VisuoTact_smdl.json');
opt.verbosity = 2;
opt.glm.useDummyRegressor = false;

fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);
