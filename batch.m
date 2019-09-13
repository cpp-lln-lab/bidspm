%% Run batches
WD = pwd;

opt = getOption();
check_dependencies();


cd(WD); mr_removeDummies(opt);
cd(WD); mr_batchSPM12_BIDS_STC_decoding(opt);
cd(WD); mr_batchSPM12_BIDS_SpatialPrepro_decoding(opt);
cd(WD); mr_batchSPM12_BIDS_Smoothing_decoding(6, opt);
cd(WD); mr_batchSPM12_BIDS_FFX_decoding(1, 6, opt);
cd(WD); mr_batchSPM12_BIDS_FFX_decoding(2, 6, opt);
cd(WD); mr_batchSPM12_BIDS_RFX_decoding(1, 6, 6)
cd(WD); mr_batchSPM12_BIDS_RFX_decoding(2, 6, 6)

cd(WD)