% script to test your BIDS stats model on a tsv
%
% assumes there are transformations to apply in the first node of the model
%
%
% (C) Copyright 2021 Remi Gau

clear;

% FIXME
% tsv_file = fullpath_to.tsv

% FIXME
% model_file = fullpath_to_bids_stat_model.json

data = bids.util.tsvread(tsv_file);
model = BidsModel('file', model_file);
transformers = model.Nodes{1}.Transformations.Instructions;

[new_content, json] = bids.transformers(transformers, data);

% save the new TSV for inspection to make sure it looks like what we expect
bids.util.tsvwrite(fullfile(pwd, 'new_events.tsv'), new_content);
