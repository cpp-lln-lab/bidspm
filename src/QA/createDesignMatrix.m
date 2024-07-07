function X = createDesignMatrix(S)
  %
  % Return the design matrix for the structure S.
  %
  % Adapted from fMRI_GLM_efficiency
  % that only returns a filtered and detrended design matrix.
  %
  % USAGE::
  %
  %     X = createDesignMatrix(S)
  %
  % :param S: input structure with the following fields
  % :type  S: structure
  %
  %    - ``S.Ns``   : number of scans
  %    - ``S.TR``   : inter-scan interval (s)
  %    - ``S.sots`` : cell array of onset times for each condition in units of scans
  %    - ``S.durs`` : cell array of durations for each condition in units of scans
  %    - ``S.bf``   : type of HRF basis function (based on spm_get_bf.m),
  %                   default = "hrf"

  % (C) Copyright 2021 Remi Gau

  Ns = S.Ns;

  TR = S.TR;

  % Minimum time for convolution space (seconds)
  dt = 0.2;
  st = round(TR / dt);

  sots = S.sots;

  durs = S.durs;
  for j = 1:length(sots)
    if length(durs{j}) == 1
      durs{j} = repmat(durs{j}, 1, length(sots{j}));
    elseif length(durs{j}) ~= length(sots{j})
      error('Number of durations (%d) does not match number of onsets (%d) for condition %d', ...
            length(durs{j}), length(sots{j}), j);
    end
  end

  try
    bf = S.bf;
  catch
    bf = 'hrf';  % SPM's canonical HRF
    %    bf = 'Finite Impulse Response'  % FIR
  end

  if ischar(bf)
    xBF.dt     = dt;
    xBF.name   = bf;
    xBF.length = 30;
    xBF.order  = 30 / TR;
    bf = spm_get_bf(xBF);
    bf = bf.bf;
  else
    % Assume bf is a TxNk matrix of basis functions in units of dt
  end

  Nj = length(sots);
  Nk = size(bf, 2);
  Nt = Ns * st;

  %% Create neural timeseries and concolve
  s = 1:st:Nt;
  X = zeros(Ns, Nj * Nk);
  for j = 1:Nj

    u = zeros(Nt, 1);
    for i = 1:length(sots{j})
      o = [sots{j}(i) * st:st:(sots{j}(i) + durs{j}(i)) * st];
      u(round(o) + 1) = 1;
    end

    for k = 1:Nk
      b = conv(u, bf(:, k));
      X(:, (j - 1) * Nk + k) = b(s);
    end
  end
