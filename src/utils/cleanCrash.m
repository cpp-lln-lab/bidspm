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

  ext = {'png'};
  
  for i = 1:numel(ext)
  
    if ~isempty(spm_select('List', pwd, ['^.*.' ext{i} '$']))

      delete(fullfile(pwd, ['*.' ext{i}]), targetDir);

    end
  
  end
  
  
end