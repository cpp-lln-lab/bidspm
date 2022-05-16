function matlabbatch = setBatchGroupLevelContrasts(matlabbatch, opt, grpLvlCon, rfxDir)
  %
  % (C) Copyright 2019 CPP_SPM developers

  printBatchName('group level contrast estimation', opt);

  if ~isfield(grpLvlCon, 'Test')
    disp(grpLvlCon);
    errorHandling(mfilename(), ...
                  'noGroupLevelContrast', ...
                  'No group level contrast. Check your model.', ...
                  false);
  end

  if isfield(grpLvlCon, 'Contrasts')

    for j = 1:size(grpLvlCon.Contrasts, 1)

      conName = rmTrialTypeStr(grpLvlCon.Contrasts{j});

      spmMatFile = fullfile(rfxDir, conName, 'SPM.mat');

      consess{1}.tcon.name = 'GROUP';
      consess{1}.tcon.convec = 1;
      consess{1}.tcon.sessrep = 'none';

      matlabbatch = setBatchContrasts(matlabbatch, opt, spmMatFile, consess);

    end

  else

    % TODO

    notImplemented(mfilename, ...
                   'Grabbing contrast from lower levels not implemented yet.', ...
                   opt.verbosity);

  end

end
