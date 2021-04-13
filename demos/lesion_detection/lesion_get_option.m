function opt = lesion_get_option()
  %
  % Returns a structure that contains the options chosen by the user to run the source processing
  % batch workflow
  %
  % USAGE::
  %
  %  opt = Lesion_getOption()
  %
  % :returns: - :optSource: (struct)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % The directory where the data are located
  opt.dataDir = '/home/remi/gin/CVI-Datalad/data';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
