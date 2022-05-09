function download_moae_ds(download_data, clean)
  %
  % (C) Copyright 2021 Remi Gau

  if nargin < 1
    download_data = true;
  end

  if nargin < 2
    clean = false;
  end

  if download_data

    % URL of the data set to download
    URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

    working_directory = fileparts(mfilename('fullpath'));

    % clean previous runs
    if clean && exist(fullfile(working_directory, 'inputs'), 'dir')
      rmdir(fullfile(working_directory, 'inputs'), 's');
    end

    spm_mkdir(fullfile(working_directory, 'inputs'));

    %% Get data
    filename = download(URL, fullfile(working_directory, 'inputs'), true);

    fprintf('%-10s:', 'Unzipping dataset...');
    unzip(filename);
    if isOctave()
      movefile(fullfile(working_directory, 'inputs', 'MoAEpilot'), ...
               fullfile(working_directory, 'inputs', 'raw'));
      delete(filename);
    else
      movefile('MoAEpilot', fullfile(working_directory, 'inputs', 'raw'));
      delete(filename);
    end
    fprintf(1, ' Done\n\n');

  end

end
