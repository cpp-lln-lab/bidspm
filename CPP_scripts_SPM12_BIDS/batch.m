
WD = pwd;

cd(WD); mr_removeDummies();
cd(WD); mr_batchSPM12_BIDS_STC_decoding();
cd(WD); mr_batchSPM12_BIDS_SpatialPrepro_decoding();
cd(WD); mr_batchSPM12_BIDS_Smoothing_decoding(6);
cd(WD); mr_batchSPM12_BIDS_FFX_decoding(1,6);
cd(WD); mr_batchSPM12_BIDS_FFX_decoding(2,6);
cd(WD); mr_batchSPM12_BIDS_RFX_decoding(1,6,6)
cd(WD); mr_batchSPM12_BIDS_RFX_decoding(2,6,6)

cd(WD)