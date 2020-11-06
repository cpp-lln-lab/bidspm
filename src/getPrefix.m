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
                        'realign'; ...
                        'normalise'; ...
                        'funcQA'; ...
                        'smooth'; ...
                        'FFX'};

  switch lower(step)

    case 'realign'
      prefix = prefixForSTC(prefix, opt);

    case 'normalise'
      prefix = getPrefix('realign', opt);

      if ~opt.realign.useUnwarp && strcmp(opt.space, 'individual')
        prefix = [spm_get_defaults('realign.write.prefix') prefix];
      elseif opt.realign.useUnwarp
        prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      end

    case 'mean'
      prefix = getPrefix('realign', opt);

      if opt.realign.useUnwarp
        prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      end

      prefix = ['mean' prefix];

    case 'funcqa'
      prefix = getPrefix('realign', opt);

      if ~opt.realign.useUnwarp
        prefix = [spm_get_defaults('realign.write.prefix') prefix];
      elseif opt.realign.useUnwarp
        prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
      end

      motionRegressorPrefix = prefixForSTC(prefix, opt);

    case 'smooth'
      prefix = getPrefix('normalise', opt);

      if strcmp(opt.space, 'MNI')
        prefix = [spm_get_defaults('normalise.write.prefix') prefix];
      end

    case 'ffx'
      motionRegressorPrefix = prefixForSTC(prefix, opt);

      prefix = getPrefix('smooth', opt);

      if funcFWHM > 0
        prefix = [spm_get_defaults('smooth.prefix') num2str(funcFWHM) prefix];
      end

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
