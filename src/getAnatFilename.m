% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  % 
  % [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt)
  %
  % Get the filename and the directory of an anat file for a given session /
  % run.
  % Unzips the file if necessary.

  anatType = opt.anatReference.type;

  % TODO allow for the session to be referenced by a string e.g ses-retest
  anatSession = opt.anatReference.session;

  % get all anat images for that subject fo that type
  sessions = getInfo(BIDS, subID, opt, 'Sessions');
  anat = spm_BIDS(BIDS, 'data', ...
                  'sub', subID, ...
                  'ses', sessions{anatSession}, ...
                  'type', anatType);

  % TODO
  % We assume that the first anat of that type is the correct one
  % could be an issue for dataset with more than one anatomical of the same type
  anat = anat{1};
  anatImage = unzipImgAndReturnsFullpathName(anat);

  [anatDataDir, anatImage, ext] = spm_fileparts(anatImage);
  anatImage = [anatImage ext];
end
