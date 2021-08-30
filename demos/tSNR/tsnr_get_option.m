function opt = tsnr_get_option()
  %
  % Returns a structure that contains the options chosen by the user to run the source processing
  % batch workflow
  %
  % USAGE::
  %
  %  opt = tSNR_get_option()
  %
  % :returns: - :opt: (struct)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % The directory where the data are located
  opt.dir.raw = 'C:\Users\michm\Data\myphdproject\MRI\CVI-DataLad\data';
  opt.dir.raw = '/home/remi/gin/CVI-Datalad/data';

  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');

  opt.stc.skip = true;
  opt.space = 'individual';
  opt.subjects = {'CTL05'};
  opt.taskName = 'dummy';
  opt.realign.useUnwarp = false;
  %   opt.query.acq = 'midbrainThick2';

  opt.roi.atlas = 'neuromorphometrics';
  opt.roi.space = {'individual'};

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
