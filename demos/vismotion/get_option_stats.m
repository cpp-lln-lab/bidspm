function opt = get_option_stats(level)
  %
  % returns options chosen to run statistical analysis
  %
  % opt = get_option_preprocess()
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 1
    level = 'subject';
  end

  % task to analyze
  opt.taskName = 'visMotion';
  opt.pipeline.type = 'stats';

  this_dir = fileparts(mfilename('fullpath'));
  root_dir = fullfile(this_dir, '..', '..', '..', '..');
  opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
  opt.dir.preproc = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-preproc');
  opt.dir.stats = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-stats');

  opt.space = 'IXI549Space';

  % don't specify a stats model will let cpp spm run
  % and try to figure out a default model
  %
  % You can also uncomment the following lines to try a better model
  %
  %   opt.model.file = fullfile(pwd, ...
  %                             'models', ...
  %                             'model-visMotionLoc_smdl.json');

  % specify the result to compute

  % Contrasts.Name has to match one of the contrast defined in the model json file
  if strcmp(level, 'subject')

    opt.result.Nodes(1) = returnDefaultResultsStructure();
    opt.result.Nodes(1).Level = 'subject';
    opt.result.Nodes(1).Contrasts(1).Name = 'VisMot';
    opt.result.Nodes(1).Contrasts(2) = opt.result.Nodes(1).Contrasts(1);
    opt.result.Nodes(1).Contrasts(2).Name = 'VisStat';
    opt.result.Nodes(1).Output.png = true();
    opt.result.Nodes(1).Output.montage.do = true();
    opt.result.Nodes(1).Output.montage.slices = -4:2:16;
    opt.result.Nodes(1).Output.montage.orientation = 'axial';
    opt.result.Nodes(1).Output.montage.background = ...
        fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

  elseif strcmp(level, 'dataset')
    opt.result.Nodes(1) = struct('Level',  'dataset', ...
                                 'Contrasts', struct( ...
                                                     'Name', 'VisMot', ...
                                                     'Mask', false, ...
                                                     'MC', 'FWE', ...
                                                     'p', 0.05, ...
                                                     'k', 0, ...
                                                     'NIDM', true));
  end

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
