% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function cleanCrash()
  %
  % Removes any files left over from a previous unfinished run of the pipeline,
  % like any *.png imgages
  %
  % USAGE::
  %
  %   cleanCrash()
  %
  %

  files = {'spm.*.png'};

  for i = 1:numel(files)

    if ~isempty(spm_select('List', pwd, ['^' files{i} '$']))

      delete(fullfile(pwd, strrep(files{i}, '.*', '*')));

    end

  end

end
