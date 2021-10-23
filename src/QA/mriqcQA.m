function mriqcQA(opt, suffix)
  %
  %  uses the report from MRIQC (bold and T1) identify outliers using
  %  robust statistics (interquartile range).
  %
  %  https://mriqc.readthedocs.io/en/stable/iqms/bold.html
  %  https://mriqc.readthedocs.io/en/stable/iqms/t1w.html
  %
  % USAGE::
  %
  %   mriqcQA(opt, suffix);
  %
  % :param opt:
  % :type opt: structure
  % :param opt:
  % :type opt: string
  %
  % EXAMPLE::
  %
  %   opt.dir.mriqc = '/home/remi/gin/dataset/derivatives/mriqc';
  %
  %   mriqcQA(opt, 'T1w');
  %   mriqcQA(opt, 'bold');
  %
  % Dependencies (in case you want to use it as standalone):
  %
  %   - bids-matlab
  %
  % (C) Copyright 2021 Remi Gau

  inputFile = fullfile(opt.dir.mriqc, ['group_' suffix '.tsv']);

  data = bids.util.tsvread(inputFile);

  % TO improve based on suffix from BIDS schema
  if ismember(suffix, {'bold'})
    name_flip_unilateral = getFuncMetricsToFilter();
  elseif ismember(suffix, {'T1w'})
    name_flip_unilateral = getAnatMetricsToFilter();
  end

  outliers = identify_outliers(data, name_flip_unilateral);

  % print subjects' list that are outlier for at least 1 metric
  LS = data.bids_name(sum(outliers, 2) > 0);
  if ~isempty(LS)
    fprintf(1, '\n%s data: No outliers found.', suffix);
  else
    disp(LS);
  end
  fprintf(1, '\n');

end

function outliers = identify_outliers(data, name_flip_unilateral)

  % The iqr_method sub-function indentifies outliers that are higher than a
  % certain value (unilateral) or within a certain range (bilateral).
  % Each metric of interest can be "switched" (if higher values mean
  % better quality like for SNR) and can be thresholded unilateraly or not.

  for i_field = 1:size(name_flip_unilateral, 1)

    % get the values for each metric of interest
    tmp = data.(name_flip_unilateral{i_field, 1});

    % flips it if higher values mean better
    if name_flip_unilateral{i_field, 2}
      tmp = tmp * -1;
    end

    % determines if threshold is unilateral or bilateral
    if name_flip_unilateral{i_field, 3}
      unilat = 2;
    else
      unilat = 1;
    end

    % identifies outliers.
    [outliers(:, i_field)] = iqr_method(tmp, unilat); %#ok<SAGROW>

  end

end

function name_flip_unilateral = getAnatMetricsToFilter()
  %
  % What follows is a list of the different metric used for T1
  % (mostly copy pasta from the MRIQC docs)
  %
  % CJV  =  coefficient of joint variation
  %         Lower values are better.
  % CNR  =  contrast-to-noise ratio
  %         Higher values indicate better quality.1
  % SNR  =  signal-to-noise ratio ; calculated within the tissue mask.
  %         Higher values indicate better quality ;
  % SNRd =  Dietrich's SNR ; using the air background as reference.
  %         Higher values indicate better quality ;
  % EFC  =  Entropy-focus criterion
  %         Lower values are better.
  % FBER =  Foreground-Background energy ratio
  %         Higher values are better.
  % inu_* (nipype interface to N4ITK) = summary statistics (max, min and median)
  %         of the INU field as extracted by the N4ITK algorithm [Tustison2010].
  %         Values closer to 1.0 are better.
  % art_qi1(): Detect artifacts in the image using the method described
  %               in [Mortamet2009]. The QI1 is the proportion of voxels with intensity
  %               corrupted by artifacts normalized by the number of voxels in the
  %               background.
  %             Lower values are better.
  % wm2max(): The white-matter to maximum intensity ratio is the median
  %               intensity within the WM mask over the 95% percentile of the full
  %               intensity distribution, that captures the existence of long tails
  %               due to hyper-intensity of the carotid vessels and fat.
  %           Values should be around the interval [0.6, 0.8].

  name_flip_unilateral = {
                          'cjv',      false,  true
                          'cnr',      true,   true
                          'snr_gm',   true,   true
                          'snr_wm',   true,   true
                          'snrd_gm',  true,   true
                          'snrd_wm',  true,   true
                          'efc',      false,  true
                          'fber',     true,   true
                          'qi_1',     false,  true
                          'inu_med',  false,  true
                          'wm2max',   false,  false
                         };

end

function name_flip_unilateral = getFuncMetricsToFilter()
  %
  % What follows is a list of the different metric used for BOLD
  % (mostly copy pasta from the MRIQC docs)
  %
  % efc   =   Entropy-focus criterion ; Lower values are better.
  % fber  =   Foreground-Background energy ratio ;  Higher values are better.
  % DVARS =   "signal variability"
  %             - dvars_nstd
  %             - dvars_std
  %             - dvars_vstd
  % fd_per =  framewise diplacement - percentage of time points above 0.2 mm
  % fd_mean = mean framewise diplacement
  % gsr =     Ghost to Signal Ratio
  % aor =     AFNI's outlier ratio - Mean fraction of outliers per fMRI
  %           volume as given by AFNI's 3dToutcount.
  % snr =     signal to noise ratio
  % tsnr =    Temporal SNR

  name_flip_unilateral = {
                          'aor',        false,  true
                          'dvars_nstd', false,  true
                          'dvars_std',  false,  true
                          'dvars_vstd', false,  true
                          'efc',        false,  true
                          'fber',       true,   true
                          'fd_mean',    false,  true
                          'fd_perc',    false,  true
                          'gsr_x',      true,   true
                          'gsr_y',      true,   true
                          'snr',        true,   true
                          'tsnr',       true,   true
                         };

end

function [I] = iqr_method(a, out)
  %
  % Returns a logical vector that flags outliers as 1s based
  % on the IQR (interquantile range) methods described in Wilcox 2012 p 96-97.
  %
  % Uses Carling's modification of the boxplot rule.
  %
  % An observation Xi is declared an outlier if:
  %
  %   Xi<M-k(q2-q1) or Xi>M+k(q2-q1)
  %
  % where:
  %  - M is the sample median
  %  - k = (17.63n - 23.64) / (7.74n - 3.71),
  %   - where n is the sample size.
  %
  % INPUT a is a vector of data
  %       out determines the thresholding 1 bilateral 2 unilateral
  %
  % OUTPUTS: I =     logical vector with 1s for outliers
  %          value = IQR, the inter-quartile range
  %
  % Cyril Pernet - spmup - adapted from Corr_toolbox
  % https://github.com/CPernet/spmup
  % ----------------------------------------
  % (C) Copyright 2016 Cyril Pernet

  if nargin == 1
    out = 1;
  end

  a = a(:);
  n = length(a);

  % inter-quartile range
  j = floor(n / 4 + 5 / 12);

  y = sort(a);

  g = (n / 4) - j + (5 / 12);

  q1 = (1 - g) .* y(j) + g .* y(j + 1);

  k = n - j + 1;
  q2 = (1 - g) .* y(k) + g .* y(k - 1);

  value = q2 - q1;

  % outliers
  M = median(a);
  k = (17.63 * n - 23.64) / (7.74 * n - 3.71);
  if out == 1
    I = a < (M - k * value) | a > (M + k * value);
  else
    I = a > (M + k * value); % only reject data with a too high value
  end
  I = I + isnan(a);

end
