function cleanCrash()
  %
  % Removes any files left over from a previous unfinished run of the pipeline,
  % like any ``*.png`` imgages
  %
  % USAGE::
  %
  %   cleanCrash()
  %
  %

  % (C) Copyright 2020 bidspm developers

  files = {'spm.*.png'};

  for i = 1:numel(files)

    if ~isempty(spm_select('List', pwd, ['^' files{i} '$']))

      delete(fullfile(pwd, strrep(files{i}, '.*', '*')));

    end

  end

end
