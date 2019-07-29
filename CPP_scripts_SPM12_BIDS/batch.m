clear
clc
close all

addToolboxs2Path = 1 ;

% If toolboxes are not in the MATLAB Directory and needed to be added to
% the path
if addToolboxs2Path
    addpath('D:\Dropbox\Code\MATLAB\Neuroimaging\NiftiTools')
    addpath('D:\Dropbox\Code\MATLAB\Neuroimaging\SPM\spm12')
end


WD = pwd;

check_dependencies();
opt = getOption();
cd(WD); mr_removeDummies(opt);
cd(WD); mr_batchSPM12_BIDS_STC_decoding(opt);
% cd(WD); mr_batchSPM12_BIDS_SpatialPrepro_decoding();
% cd(WD); mr_batchSPM12_BIDS_Smoothing_decoding(6);
% cd(WD); mr_batchSPM12_BIDS_FFX_decoding(1,6);
% cd(WD); mr_batchSPM12_BIDS_FFX_decoding(2,6);
% cd(WD); mr_batchSPM12_BIDS_RFX_decoding(1,6,6)
% cd(WD); mr_batchSPM12_BIDS_RFX_decoding(2,6,6)

cd(WD)
