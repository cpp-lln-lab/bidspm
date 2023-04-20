% (C) Copyright 2023 Remi Gau
%
% Validate all models in the demo folder
%
% Mostly for maintenance purposes:
% ensures that all the models of all demos are valid.
%

this_dir = fileparts(mfilename('fullpath'));

addpath(fullfile(this_dir, '..'));

bidspm();

% get full path list of all the directories in this_dir
dirs = spm_select('FPList', this_dir, 'dir');

for i_dir = 1:size(dirs, 1)

  model_dir = fullfile(deblank(dirs(i_dir, :)), 'models');

  if exist(model_dir, 'dir') == 7

    models = spm_select('FPList', model_dir, '.*smdl.json$');

    for i_model = 1:size(models, 1)
      disp(models(i_model, :));
      bm = BidsModel('file', deblank(models(i_model, :)));
      bm.validate();
      bm.validateConstrasts();
    end

  end
end
