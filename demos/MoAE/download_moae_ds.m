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

    working_directory = fileparts(mfilename('fullpath'));

    % clean previous runs
    if clean && exist(fullfile(working_directory, 'inputs'), 'dir')
      rmdir(fullfile(working_directory, 'inputs'), 's');
    end

    spm_mkdir(fullfile(working_directory, 'inputs'));

    %% Get data
    bids.util.download_ds('source', 'spm', ...
                          'demo', 'moae', ...
                          'out_path', fullfile(working_directory, 'inputs', 'raw'), ...
                          'force', true);

  end

end
