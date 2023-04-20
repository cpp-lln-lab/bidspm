function rtdURL = returnRtdURL(page, anchor)
  %
  % USAGE::
  %
  %   rtdURL = returnRtdURL()
  %

  % (C) Copyright 2021 bidspm developers

  if nargin < 1 || isempty(page)
    page = 'general_information';
  end
  if nargin < 2
    anchor = '';
  else
    anchor = ['#' anchor];
  end
  rtdURL = ['https://bidspm.readthedocs.io/en/latest/' page '.html' anchor];
end
