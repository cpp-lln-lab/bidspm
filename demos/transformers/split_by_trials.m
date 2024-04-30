% In this example we use a matlab script to generate a series of transformations
% and apply them to the content of a TSV file.
%
% This also shows how to edit the bids stats model directly,
% so you can directly "paste" the series of transformations into the JSON
% of your BIDS stats model.
%
% ---
%
% The transformations include:
%
% - "merge" certain trial type by renaming them using the Replace transformer
% - "split" the trials of certain conditions
%
% For MVPA analyses, the latter can be used to have 1 beta per trial
% (and not 1 per run per condition).
%
% You can find a list of the available variables transformations
% in the bids matlab doc:
% - https://bids-matlab.readthedocs.io/en/main/variable_transformations.html
% on the variable-transforms repository
% - https://github.com/bids-standard/variable-transform
%
% (C) Copyright 2021 Remi Gau

clear;

% conditions_to_split = {'CONG_LEFT'
%                        'CONG_RIGHT'
%                        'INCONG_VL_PR'
%                        'INCONG_VR_PL'
%                        'P_LEFT'
%                        'P_RIGHT'
%                        'V_LEFT'
%                        'V_RIGHT'};

% same but using as regular expressions
conditions_to_split = {'^.*LEFT$'
                       '^.*RIGHT$'
                       '^INCONG.*$'};

% columns headers where to store the new conditions
headers = {'LEFT'
           'RIGHT'
           'INCONG'};

tsv_file = fullfile(pwd, 'data', 'sub-03_task-VisuoTact_run-02_events.tsv');

data = bids.util.tsvread(tsv_file);

%% merge responses

transformers{1}.Name = 'Replace';
transformers{1}.Input = 'trial_type';
transformers{1}.Replace = struct('key', '^RESPONSE.*', 'value', 'RESPONSE');
transformers{1}.Attribute = 'value';

%% split by trial

for i = 1:numel(conditions_to_split)

  % create a new column where each event of a condition is labelled
  % creates a "tmp" and "label" columns that are deleted after.
  transformers{end + 1}.Name = 'Filter'; %#ok<*SAGROW>
  transformers{end}.Input = 'trial_type';
  transformers{end}.Query = ['trial_type==' conditions_to_split{i}];
  transformers{end}.Output = 'tmp';

  transformers{end + 1}.Name = 'LabelIdenticalRows';
  transformers{end}.Cumulative = true;
  transformers{end}.Input = {'tmp'};
  transformers{end}.Output = {'label'};

  transformers{end + 1}.Name = 'Concatenate';
  transformers{end}.Input = {'tmp', 'label'};
  transformers{end}.Output = headers(i);

  % clean up
  % insert actual NaN
  transformers{end + 1}.Name = 'Replace';
  transformers{end}.Input = headers(i);
  transformers{end}.Replace = struct('key', '^NaN.*', 'value', 'n/a');
  transformers{end}.Attribute = 'value';

  % remove temporary columns
  transformers{end + 1}.Name = 'Delete';
  transformers{end}.Input = {'tmp', 'label'};

end

[new_content, json] = bids.transformers(transformers, data);

% save the new TSV for inspection to make sure it looks like what we expect
bids.util.tsvwrite(fullfile(pwd, 'new_events.tsv'), new_content);

% generate the transformation section that can be added to the bids stats model
bids.util.jsonencode(fullfile(pwd, 'transformers.json'), json);

%% update the BIDS stats model

model_file = fullfile(pwd, 'models', 'model-VisuoTact_smdl.json');

bm = BidsModel('file', model_file);
bm.Nodes{1}.Transformations.Instructions = transformers;
bm.write(model_file);

%% generate the mat file that SPM will use to specify the model sor the run 2 of subject 3

tsvFile = fullfile(pwd, 'data', 'sub-03_task-VisuoTact_run-02_events.tsv');

opt.model.file = model_file;
opt.verbosity = 2;
opt.glm.useDummyRegressor = false;

fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);
