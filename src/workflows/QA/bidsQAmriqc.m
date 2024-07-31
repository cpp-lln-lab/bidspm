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
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
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
    nameFlipUnilateral = getFuncMetricsToFilter();
  elseif ismember(suffix, {'T1w'})
    nameFlipUnilateral = getAnatMetricsToFilter();
  end

  outliers = identifyOutliers(data, nameFlipUnilateral);

  % print subjects' list that are outlier for at least 1 metric
  LS = data.bids_name(sum(outliers, 2) > 0);
  if ~isempty(LS)
    fprintf(1, '\n%s data: No outliers found.', suffix);
  else
    disp(LS);
  end
  fprintf(1, '\n');

end

function outliers = identifyOutliers(data, nameFlipUnilateral)

  % The iqrMethod sub-function identifies outliers that are higher than a
  % certain value (unilateral) or within a certain range (bilateral).
  % Each metric of interest can be "switched" (if higher values mean
  % better quality like for SNR) and can be thresholded unilaterally or not.

  for i_field = 1:size(nameFlipUnilateral, 1)

    % get the values for each metric of interest
    tmp = data.(nameFlipUnilateral{i_field, 1});

    % flips it if higher values mean better
    if nameFlipUnilateral{i_field, 2}
      tmp = tmp * -1;
    end

    % determines if threshold is unilateral or bilateral
    if nameFlipUnilateral{i_field, 3}
      unilat = 2;
    else
      unilat = 1;
    end

    % identifies outliers.
    [outliers(:, i_field)] = computeRobustOutliers(tmp, 'outlierType', 's-outliers');

  end

end

function nameFlipUnilateral = getAnatMetricsToFilter()
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

  nameFlipUnilateral = {'cjv',      false,  true; ...
                        'cnr',      true,   true; ...
                        'snr_gm',   true,   true; ...
                        'snr_wm',   true,   true; ...
                        'snrd_gm',  true,   true; ...
                        'snrd_wm',  true,   true; ...
                        'efc',      false,  true; ...
                        'fber',     true,   true; ...
                        'qi_1',     false,  true; ...
                        'inu_med',  false,  true; ...
                        'wm2max',   false,  false};

end

function nameFlipUnilateral = getFuncMetricsToFilter()
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
  % fd_per =  framewise displacement - percentage of time points above 0.2 mm
  % fd_mean = mean framewise displacement
  % gsr =     Ghost to Signal Ratio
  % aor =     AFNI's outlier ratio - Mean fraction of outliers per fMRI
  %           volume as given by AFNI's 3dToutcount.
  % snr =     signal to noise ratio
  % tsnr =    Temporal SNR

  nameFlipUnilateral = {'aor',        false,  true; ...
                        'dvars_nstd', false,  true; ...
                        'dvars_std',  false,  true; ...
                        'dvars_vstd', false,  true; ...
                        'efc',        false,  true; ...
                        'fber',       true,   true; ...
                        'fd_mean',    false,  true; ...
                        'fd_perc',    false,  true; ...
                        'gsr_x',      true,   true; ...
                        'gsr_y',      true,   true; ...
                        'snr',        true,   true; ...
                        'tsnr',       true,   true};

end
