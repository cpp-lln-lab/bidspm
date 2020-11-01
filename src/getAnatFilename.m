% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt)
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
