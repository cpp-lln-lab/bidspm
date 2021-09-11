function stats = fmrwhy_qc_calculate_tSNR(bids_dir, sub, functional_fn, options)
    % function stats = fmrwhy_qc_calculate_tSNR(bids_dir, sub, ses, task, run)
    % Function to calculate temporal SNR from single run of (masked) fMRI timeseries data

    % First access and reshape the functional data: 4D to 2D
    nii = nii_tool('load', functional_fn);
    data_4D = double(nii.img);
    [Ni, Nj, Nk, Nt] = size(data_4D);
    data_2D = reshape(data_4D, Ni * Nj * Nk, Nt); % [voxels, time]
    data_2D = data_2D'; % [time, voxels]

    % Get masks
    masks = fmrwhy_util_loadMasks(bids_dir, sub, options);

    % Remove linear and quadratic trend per voxel
    data_2D_detrended = fmrwhy_util_detrend(data_2D, 2); % [time, voxels]

    % Calculate mean
    data_2D_mean = nanmean(data_2D_detrended); % [1, voxels]

    % Remove mean
    data_2D_demeaned = data_2D_detrended - data_2D_mean; % [time, voxels]

    % Calculate standard deviation
    data_2D_stddev = std(data_2D_detrended); % [1, voxels]

    % Calculate Z-statistic
    data_2D_zstat = data_2D_demeaned ./ data_2D_stddev;
    data_2D_zstat(isnan(data_2D_zstat)) = 0;
    data_2D_zstat_ts = nanmean(abs(data_2D_zstat), 2); % perhaps this should only be done within brain mask?
    Zstat_mean = nanmean(data_2D_zstat_ts); % perhaps this should only be done within brain mask?

    % Calculate variance
%     data_2D_var = var(data_2D_detrended);

    % Calculate percentage signal change: [I(t) - mean(I)]/mean(I)*100
    data_2D_psc = 100 * (data_2D_detrended ./ data_2D_mean) - 100;
    data_2D_psc(isnan(data_2D_psc)) = 0;

    % Calculate tSNR
    tSNR_2D = data_2D_mean ./ data_2D_stddev;
    tSNR_mean_brain = nanmean(tSNR_2D(masks.brain_mask_I));
    tSNR_mean_GM = nanmean(tSNR_2D(masks.GM_mask_I));
    tSNR_mean_WM = nanmean(tSNR_2D(masks.WM_mask_I));
    tSNR_mean_CSF = nanmean(tSNR_2D(masks.CSF_mask_I));

    % Prepare 3D and 4D images
%     data_3D_mean = reshape(data_2D_mean, Ni, Nj, Nk);
%     data_3D_var = reshape(data_2D_var, Ni, Nj, Nk);
%     data_3D_stddev = reshape(data_2D_stddev, Ni, Nj, Nk);
%     tSNR_3D = reshape(tSNR_2D, Ni, Nj, Nk);

    data_4D_psc = reshape(data_2D_psc', Ni, Nj, Nk, Nt);
    data_4D_detrended = reshape(data_2D_detrended', Ni, Nj, Nk, Nt);
    data_4D_demeaned = reshape(data_2D_demeaned', Ni, Nj, Nk, Nt);

    stats = struct;
    % Single values
    stats.tSNR_mean_brain = tSNR_mean_brain;
    stats.tSNR_mean_GM = tSNR_mean_GM;
    stats.tSNR_mean_WM = tSNR_mean_WM;
    stats.tSNR_mean_CSF = tSNR_mean_CSF;
    stats.Zstat_mean = Zstat_mean;
    % Single parameter timeseries
    stats.data_2D_zstat_ts = data_2D_zstat_ts;
%     % 3D images
%     stats.data_3D_mean = data_3D_mean;
%     stats.data_3D_var = data_3D_var;
%     stats.data_3D_stddev = data_3D_stddev;
%     stats.data_3D_tsnr = tSNR_3D;
    % 4D image timeseries
    stats.data_4D_psc = data_4D_psc;
    stats.data_4D_detrended = data_4D_detrended;
    stats.data_4D_demeaned = data_4D_demeaned;

    %% Display metrics in command window
    % disp(['Mean Zscore: ' num2str(Zstat_mean)])
    % disp(['tSNR (brain): ' num2str(tSNR_brain)])
    % disp(['tSNR (GM): ' num2str(tSNR_GM)])
    % disp(['tSNR (WM): ' num2str(tSNR_WM)])
    % disp(['tSNR (CSF): ' num2str(tSNR_CSF)])
