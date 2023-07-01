% script to generate template method section
%
% (C) Copyright 2022 Remi Gau

clc;
clear;
close all;

WK = fileparts(mfilename('fullpath'));

root_dir = fullfile(WK, '..');
face_rep_dir = fullfile(root_dir, 'demos', 'face_repetition');

addpath(root_dir);

% move to the facerep folder and grad the data
cd(face_rep_dir);

download_data = true;

% Gets data and converts it to BIDS
if download_data
  bidspm();
  %   download_face_rep_ds(download_data);
end

% options
opt.dir.input = fullfile(face_rep_dir, 'outputs', 'raw');
opt.dir.output = WK;

opt = checkOptions(opt);

% dataset descriptor
bidsReport(opt);

% preprocessing
boilerplate(opt, 'outputPath', fullfile(WK, 'source', 'examples'), ...
            'pipelineType', 'preprocess');

% stats
opt.model.file = fullfile(face_rep_dir, ...
                          'models', ...
                          'model-faceRepetition_smdl.json');
opt.fwhm.contrast = 0;
opt.designType = 'event';

output = boilerplate(opt, 'outputPath', fullfile(WK, 'source', 'examples'), ...
                     'pipelineType', 'stats');

cd(WK);
