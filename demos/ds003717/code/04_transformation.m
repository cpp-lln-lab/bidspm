% This script takes one of the TSV of the dataset
% and uses a Replace transformer to replace the values:
%
% - AV_n10_SNR
% - AV_n5_SNR
%
% in the trial type column by the value AV
%
% This is an example of how to design a transformer
% to then use it in your bids stats model.
% One could also use the same approach to create a transformer
% with many more steps.
%

% (C) Copyright 2022 Remi Gau

% load the content of the TSV file
file = 'sub-01_task-SESS01_events.tsv';
data = bids.util.tsvread(fullfile(pwd, file));

% create the transformer
replace = struct('key',   {'AV_n10_SNR'; 'AV_n5_SNR'}, ...
                 'value', 'AV');
transformer = struct('Name',  'Replace', ...
                     'Input', 'trial_type', ...
                     'Attribute', 'value', ...
                     'Replace', replace);

% apply the transformer
[new_content, json] = bids.transformers(transformer, data);

% write the new TSV file so we can compare it with the original
% to make sure the transformer worked as expected
bids.util.tsvwrite(fullfile(pwd, 'new.tsv'), new_content);

% write the JSON 'snippet' that corresponds to the transformer
% so we can copy paste in our bids stats model
bids.util.jsonwrite(fullfile(pwd, 'new.json'), json);
