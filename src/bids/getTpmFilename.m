
function [gm, wm, csf] = getTpmFilename(BIDS, anatImage, res, space)
  %
  % Gets the fullpath filenames of the tissue probability maps (TPM)
  %
  % USAGE::
  %
  %   [gm, wm, csf] = getTpmFilenames(BIDS, opt, subLabel, space, res)
  %
  % :param BIDS:
  % :type BIDS: structure
  % :param opt:
  % :param opt: structure
  % :param anatImage:
  % :param anatImage: string
  % :param space:
  % :param space: string
  % :param res:
  % :param res: string
  %
  % :returns: - :gm: (string) grey matter TPM
  %           - :wm: (string) white matter TPM
  %           - :csf: (string) csf matter TPM
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 4
    res = '';
    space = 'individual';
  end

  if strcmp(space, 'MNI')
    space = 'IXI549Space';
  end
  
  bf = bids.File(anatImage);
  
  filter = bf.entities;
  filter.extension = bf.ext;
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
