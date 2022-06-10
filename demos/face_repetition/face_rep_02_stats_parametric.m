% This script will run the parametric model and contrasts
% on the the face repetition dataset from SPM.
%
%
% (C) Copyright 2019 Remi Gau

% TODO
% - create the contrast similar to the tuto

clear;
clc;

downloadData = true;

addpath(fullfile(pwd, '..', '..'));

cpp_spm();

%% Gets data and converts it to BIDS
if downloadData
  download_face_rep_ds(downloadData);
end

opt = face_rep_get_option_results();

opt.model.file = spm_file(opt.model.file, 'basename', 'model-faceRepetitionParametric_smdl');
opt.model.bm = BidsModel('file', opt.model.file);

bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);

% bidsResults(opt);
