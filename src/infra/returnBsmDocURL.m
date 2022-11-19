function url = returnBsmDocURL(section)
  %
  % USAGE::
  %
  %   url = returnBsmDocURL()
  %

  % (C) Copyright 2021 bidspm developers

  baseUrl = 'https://bids-standard.github.io/stats-models/_autosummary/';

  switch lower(section)
    case 'hrf'
      url = [baseUrl 'bsmschema.models.HRF.html'];

    case {'options', 'hpf'}
      url = [baseUrl 'bsmschema.models.Options.html'];
  end
end
