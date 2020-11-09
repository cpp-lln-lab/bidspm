% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function optSource = getOptionSource()
  %
  % Returns a structure that contains the options chosen by the user to run the source processing
  % batch workflow
  %
  % USAGE::
  %
  %   optSource = getOptionSource()
  %
  % :returns: - :optSource: (struct)
  
if nargin < 1
  optSource = [];
end

% Set the folder where sequences folders exist
optSource.sourceDir = '/Users/barilari/Desktop/DICOM_UCL_leuven/renamed/sub-pilot001/ses-002/MRI';

% List of the sequences that you want to skip (folder name pattern)
optSource.sequenceToIgnore = {'AAHead_Scout', ...
                              'b1map', ...
                              't1', ...
                              'gre_field'};

% Number of volumes to discard ad dummies, (0 is default)
optSource.nbDummies = 5;

% List of the sequences where you want to remove dummies (folder name pattern)
optSource.sequenceRmDummies = {'cmrr_mbep2d_p3_mb2_1.6iso_AABrain', ...
                               'cmrr_mbep2d_p4_mb2_750um_AAbrain'};

% Set data format conversion (0 is default)

% 0:  SAME
% 2:  UINT8   - unsigned char
% 4:  INT16   - signed short
% 8:  INT32   - signed int
% 16: FLOAT32 - single prec. float
% 64: FLOAT64 - double prec. float

optSource.dataType = 0;

% Boolean to enable gzip of the new 4D file (0 is default)
optSource.zip = 0;

% Check the options provided
optSource = checkOptionsSource(optSource);

end
