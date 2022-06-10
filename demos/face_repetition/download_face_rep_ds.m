function download_face_rep_ds(download_data)
  %
  %
  % (C) Copyright 2022 Remi Gau

  if download_data

    WD = pwd;

    bids.util.download_ds('source', 'spm', ...
                          'demo', 'facerep', ...
                          'force', true, ...
                          'verbose', true, ...
                          'out_path', fullfile(WD, 'inputs', 'source'));

    % conversion script from bids-matlab
    cd('../../lib/bids-matlab/demos/spm/facerep/code');
    convert_facerep_ds(fullfile(WD, 'inputs', 'source'), ...
                       fullfile(WD, 'outputs', 'raw'));

    cd(WD);

  end
end
