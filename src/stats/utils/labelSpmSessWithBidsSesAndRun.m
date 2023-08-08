function   SPM = labelSpmSessWithBidsSesAndRun(SPM)
  %
  % Adds the bids session and run label to each SPM.Sess.
  %
  % USAGE::
  %
  %
  % :param SPM: content of SPM.mat
  % :type  SPM: structure
  %
  %
  %

  % (C) Copyright 2023 bidspm developers

  if ~isfield(SPM, 'xY') || ~isfield(SPM, 'Sess')
    return
  end

  for i = 1:numel(SPM.Sess)

    rows = SPM.Sess(i).row;
    files = SPM.xY.P(rows, :);
    bf = bids.File(deblank(files(1, :)));

    run = '';
    if isfield(bf.entities, 'run')
      run = bf.entities.run;
    end
    ses = '';
    if isfield(bf.entities, 'ses')
      ses = bf.entities.ses;
    end

    SPM.Sess(i).run = run;
    SPM.Sess(i).ses = ses;

  end
end
