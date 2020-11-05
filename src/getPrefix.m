% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM)
  % [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM)
  %
  % generates prefix to append to file name to look for

  if nargin < 3
    funcFWHM = 0;
  end

  prefix = '';
  motionRegressorPrefix = '';

  allowedPrefixCases = {
                        'STC'; ...
                        'preprocess'; ...
                        'smoothing_space-individual'; ...
                        'smoothing_unwarp-0'; ...
                        'smoothing'; ...
                        'FFX_space-individual'; ...
                        'FFX'};

  switch step

    case 'STC'

    case 'preprocess'
      prefix = prefixForSTC(prefix, opt);
      
    case 'preprocess_unwarp-0'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('realign.write.prefix') prefix];

    %%
    case 'smoothing'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      prefix = [spm_get_defaults('normalise.write.prefix') prefix];
    
    case 'smoothing_space-MNI'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('normalise.write.prefix') prefix];
      
    case 'smoothing_space-individual'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('unwarp.write.prefix') prefix];

    case 'smoothing_unwarp-0_space-individual'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('realign.write.prefix') prefix];
      
      
    %%
    case 'FFX'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      prefix = [spm_get_defaults('normalise.write.prefix') prefix];
      
    case 'FFX_space-individual'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      
    case 'FFX_unwarp-0'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('normalise.write.prefix') prefix];
      
    case 'FFX_unwarp-0_space-individual'
      prefix = prefixForSTC(prefix, opt);
      prefix = [spm_get_defaults('realign.write.prefix') prefix];
      
    %%  
    otherwise

      fprintf(1, '\nAllowed prefix cases:\n');
      for iCase = 1:numel(allowedPrefixCases)
        fprintf(1, '- %s\n', allowedPrefixCases{iCase});
      end

      errorStruct.identifier = 'getPrefix:unknownPrefixCase';
      errorStruct.message = sprintf('%s%s\n%s', ...
                                    ['This prefix case you have requested ' ...
                                     'does not exist: '], step, ...
                                    'See allowed cases above');
      error(errorStruct);

  end
  
  if any(ismember(step, 'FFX'))
    % Check which level of smoothing is applied
    if funcFWHM > 0
      prefix = [spm_get_defaults('smooth.prefix') num2str(funcFWHM) prefix];
    end
  end

end

function prefix = prefixForSTC(prefix, opt)
  % Check the slice timing information is not in the metadata and not added
  % manually in the opt variable.
  if (isfield(opt.metadata, 'SliceTiming') && ...
      ~isempty(opt.metadata.SliceTiming)) || ...
          ~isempty(opt.sliceOrder)
    prefix = [spm_get_defaults('slicetiming.prefix') prefix];
  end
end
