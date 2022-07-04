function status = checkFmriprep(BIDS)
  %
  %  only fmriprep version >= 1.2 supported
  %
  % USAGE::
  %
  %     status = checkFmriprep(BIDS)
  %
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type BIDS: struct
  %
  % (C) Copyright 2022 CPP_SPM developers

  status =  true;

  [name, version] = generatedBy(BIDS);

  if ~strcmpi(name, 'fmriprep')
    status =  false;
    return
  end

  tmp = strsplit(version, '.');

  major = str2num(tmp{1});
  minor = str2num(tmp{2});
  patch = str2num(tmp{3});

  if major > 1
    return

  elseif major == 1 && minor >= 2
    return

  else
    status =  false;

  end

end
