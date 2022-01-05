% (C) Copyright 2021 CPP_SPM developers
% Adapted from Renzo Huber's scripts

clear;
clc;

run ../../initCppSpm.m;

%% --- parameters

subLabel = 'pilot001';

prefix = 'moco_';
task = 'gratingBimodalMotion';

first_vol_bold = 2;
first_vol_vaso = 1;

opt = high_res_get_option();

use_schema = false;
derivatives = bids.layout(opt.derivativesDir, use_schema);

%% --- run

runs = bids.query(derivatives, 'runs', 'sub', subLabel, 'task', task, 'suffix', 'vaso');

matlabbatch{1}.spm.spatial.realign = return_realign_batch(prefix);
matlabbatch{2}.spm.spatial.realign = return_realign_batch(prefix);

for i = 1:numel(runs)

  bold_file = bids.query(derivatives, 'data', ...
                         'sub', subLabel, ...
                         'task', task, ...
                         'run', runs{i}, ...
                         'prefix', '', ...
                         'extension', '.nii', ...
                         'suffix', 'bold');
  assert(numel(bold_file) == 1);

  fprintf('\nAdding file to batch 1:\n %s', ['run ' bold_file{1}]);

  bold_frames = get_frames(bold_file{1}, first_vol_bold);
  matlabbatch{1}.spm.spatial.realign.estwrite.data{i} = cellstr(bold_frames);

  vaso_file =  bids.query(derivatives, 'data', ...
                          'sub', subLabel, ...
                          'task', task, ...
                          'run', runs{i}, ...
                          'prefix', '', ...
                          'extension', '.nii', ...
                          'suffix', 'vaso');
  assert(numel(vaso_file) == 1);

  fprintf('\nAdding file to batch 2:\n %s', ['run ' vaso_file{1}]);

  vaso_frames = get_frames(vaso_file{1}, first_vol_vaso);
  matlabbatch{2}.spm.spatial.realign.estwrite.data{i} = cellstr(vaso_frames);

end

batchName = 'motionCorretion';
saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

exit;

%% sub functions

function frames = get_frames(filename, first_frame)
  [pth, img, ext] = spm_fileparts(filename);
  hdr = spm_vol(filename);
  nb_frames = numel(hdr);
  frames = spm_select('ExtFPList', pth, ['^' img ext '$'], first_frame:2:nb_frames);
end

function realign = return_realign_batch(prefix, mask)

  if nargin < 2
    mask = '';
  end

  realign.estwrite.eoptions.quality = 1;
  realign.estwrite.eoptions.sep = 1.2;
  realign.estwrite.eoptions.fwhm = 1;
  % if you want to use the first, use rtm = 0,
  %   if you want to use the mean use rtm = 1
  realign.estwrite.eoptions.rtm = 0;
  realign.estwrite.eoptions.interp = 4;
  realign.estwrite.eoptions.wrap = [0 0 0];
  realign.estwrite.eoptions.weight = {mask};
  realign.estwrite.roptions.which = [2 1];
  realign.estwrite.roptions.interp = 4;
  realign.estwrite.roptions.wrap = [0 0 0];
  realign.estwrite.roptions.mask = 1;
  realign.estwrite.roptions.prefix = prefix;

end
