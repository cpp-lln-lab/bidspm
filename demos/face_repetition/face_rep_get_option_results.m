function opt =  face_rep_get_option_results()
  %
  % (C) Copyright 2021 Remi Gau

  opt = [];

  opt.pipeline.type = 'stats';

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

  opt.model.file = fullfile( ...
                            fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-faceRepetition_smdl.json');

  opt.QA.glm.do = false;

  % Specify the result to compute
  opt.result.Nodes(1) = returnDefaultResultsStructure();

  opt.result.Nodes(1).Level = 'subject';

  opt.result.Nodes(1).Contrasts(1).Name = 'faces_gt_baseline_1';

  opt.result.Nodes(1).Contrasts(1).MC =  'FWE';
  opt.result.Nodes(1).Contrasts(1).p = 0.05;
  opt.result.Nodes(1).Contrasts(1).k = 5;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Nodes(1).Output.png = true();
  opt.result.Nodes(1).Output.csv = true();
  opt.result.Nodes(1).Output.thresh_spm = true();
  opt.result.Nodes(1).Output.binary = true();

  % MONTAGE FIGURE OPTIONS
  opt.result.Nodes(1).Output.montage.do = true();
  opt.result.Nodes(1).Output.montage.slices = -26:3:6; % in mm
  opt.result.Nodes(1).Output.montage.orientation = 'axial';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
