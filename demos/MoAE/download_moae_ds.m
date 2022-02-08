function download_moae_ds(downloadData)
  %
  % (C) Copyright 2021 Remi Gau

  if downloadData

    % URL of the data set to download
    URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

    working_directory = fileparts(mfilename('fullpath'));

    % clean previous runs
    if exist(fullfile(working_directory, 'inputs'), 'dir')
      rmdir(fullfile(working_directory, 'inputs'), 's');
    end

    spm_mkdir(fullfile(working_directory, 'inputs'));

    %% Get data
    fprintf('%-10s:', 'Downloading dataset...');
    urlwrite(URL, 'MoAEpilot.zip');
    fprintf(1, ' Done\n\n');

    fprintf('%-10s:', 'Unzipping dataset...');
    unzip('MoAEpilot.zip');
    movefile('MoAEpilot', fullfile(working_directory, 'inputs', 'raw'));
    fprintf(1, ' Done\n\n');

  end

end
