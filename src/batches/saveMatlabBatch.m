function saveMatlabBatch(matlabbatch, batchType, opt, subLabel) %#ok<INUSL>
  %
  % Saves the matlabbatch job in a .m file.
  % Environment information are saved in a .json file.
  %
  %  % USAGE::
  %
  %   saveMatlabBatch(matlabbatch, batchType, opt, [subLabel])
  %
  % :param matlabbatch:
  % :type  matlabbatch: structure
  %
  % :param batchType:
  % :type  batchType: char
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See also: checkOptions
  %
  % :param subLabel:
  % :type  subLabel: char
  %
  % The .m file can directly be loaded with the SPM batch or run directly
  % by SPM standalone or SPM docker.
  %
  % The .json file also contains heaps of info about the "environment" used
  % to set up that batch including the version of:
  %
  % - OS,
  % - MATLAB or Octave,
  % - SPM,
  % - bidspm
  %
  % This can be useful for methods writing though if the the batch is generated
  % in one environment and run in another (for example set up the batch with Octave
  % on Mac OS and run the batch with Docker SPM),
  % then this information will be of little value
  % in terms of computational reproducibility.
  %
  %

  % (C) Copyright 2019 bidspm developers

  if nargin < 4 || isempty(subLabel)
    subLabel = 'group';
  else
    subLabel = ['sub-' subLabel];
  end

  jobsDir = fullfile(opt.dir.jobs, subLabel);
  spm_mkdir(jobsDir);

  batchFileName = returnBatchFileName(batchType, '.mat');
  batchFileName = fullfile(jobsDir, batchFileName);

  msg = sprintf('Saving job in:\n\t%s', pathToPrint(opt.dir.jobs));
  logger('DEBUG', msg, 'options', opt, 'filename', mfilename());

  save(batchFileName, 'matlabbatch', '-v7');

  saveSpmScript(batchFileName);

  delete(batchFileName);

  [OS, GeneratedBy] = getEnvInfo(opt);
  GeneratedBy(1).Description = batchType;

  json.GeneratedBy = GeneratedBy;
  json.OS = OS;
  bids.util.jsonwrite(strrep(batchFileName, '.mat', '.json'), json);

end
