function [gm, wm, csf] = getTpmFilename(BIDS, anatImage, res, space)
  %
  % Gets the fullpath filenames of the tissue probability maps (TPM)
  %
  % USAGE::
  %
  %   [gm, wm, csf] = getTpmFilenames(BIDS, opt, subLabel, space, res)
  %
  % :param BIDS: dataset layout.
  %              See: bids.layout, getData
  %
  % :type  BIDS: structure
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions
  %
  % :type opt:  structure
  %
  % :param anatImage:
  % :param anatImage: char
  %
  % :param space:
  % :param space: char
  %
  % :param res:
  % :param res: char
  %
  % :return: gm
  %          grey matter TPM
  %
  % :rtype:  string
  %
  % :return: wm
  %          white matter TPM
  %
  % :rtype:  string
  %
  % :return: csf
  %          csf TPM
  %
  % :rtype:  string
  %
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 4
    res = '';
    space = 'individual';
  end

  if strcmp(space, 'MNI')
    space = 'IXI549Space';
  end

  bf = bids.File(anatImage);

  filter = bf.entities;
  filter.extension = bf.extension;
  filter.prefix = '';
  filter.suffix = 'probseg';
  filter.space = space;
  filter.res = res;

  filter.label = 'GM';
  gm = bids.query(BIDS, 'data', filter);
  gm = gm{1};

  filter.label = 'WM';
  wm = bids.query(BIDS, 'data', filter);
  wm = wm{1};

  filter.label = 'CSF';
  csf = bids.query(BIDS, 'data', filter);
  csf = csf{1};

end
