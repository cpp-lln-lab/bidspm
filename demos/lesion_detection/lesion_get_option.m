function opt = lesion_get_option()
  %
  % Returns a structure that contains the options chosen by the user to run the source processing
  % batch workflow
  %
  % USAGE::
  %
  %  opt = lesion_get_option()
  %
  % :returns: - :opt: (struct)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % The directory where the data are located
  opt.dir.raw = 'C:\Users\michm\Data\myphdproject\MRI\CVI-DataLad\data';
  opt.dir.raw = '/home/remi/gin/CVI-Datalad/data';

  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');

  opt.query.modality = 'anat';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
