function [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM)
  %
  % Generates prefix to append to file name to look for
  %
  % USAGE::
  %
  %   [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM)
  %
  % :param step:
  % :type step: string
  % :param opt: Options chosen for the analysis. See ``checkOptions()``.
  % :type opt: structure
  % :param funcFWHM:
  % :type funcFWHM: scalar
  %
  % :returns: - :prefix:
  %           - :motionRegressorPrefix:
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  prefix = '';
  motionRegressorPrefix = '';

  allowedPrefixCases = {
                        'realign'; ...
                        'normalise'; ...
                        'mean'; ...
                        'funcQA'; ...
                        'smooth'; ...
                        'FFX'};

  switch lower(step)

    case 'realign'
      prefix = prefixForSTC(prefix, opt);

    case 'normalise'
      prefix = prefixForNormalize(opt);

    case 'mean'
      prefix = prefixForMean(opt);

    case 'funcqa'
      [prefix, motionRegressorPrefix] = prefixForFuncQA(opt);

    case 'smooth'
      prefix = prefixForSmooth(opt);

    case 'ffx'

      if nargin < 3
        funcFWHM = 0;
      end

      [prefix, motionRegressorPrefix] = prefixForFFX(opt, prefix, funcFWHM);

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

function prefix = prefixForNormalize(opt)
  prefix = getPrefix('realign', opt);

  if ~opt.realign.useUnwarp && strcmp(opt.space, 'individual')
    prefix = [spm_get_defaults('realign.write.prefix') prefix];
  elseif opt.realign.useUnwarp
    prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
  end
end

function prefix = prefixForMean(opt)
  prefix = getPrefix('realign', opt);

  if opt.realign.useUnwarp
    prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
  end

  prefix = ['mean' prefix];

  if strcmp(opt.space, 'MNI')
    prefix = ['w', prefix];
  end
end

function [prefix, motionRegressorPrefix] = prefixForFuncQA(opt)

  prefix = getPrefix('realign', opt);

  if ~opt.realign.useUnwarp
    prefix = [spm_get_defaults('realign.write.prefix') prefix];
  elseif opt.realign.useUnwarp
    prefix = [spm_get_defaults('unwarp.write.prefix') prefix];
  end

  motionRegressorPrefix = prefixForSTC(prefix, opt);

end

function prefix = prefixForSmooth(opt)

  prefix = getPrefix('normalise', opt);

  if strcmp(opt.space, 'MNI')
    prefix = [spm_get_defaults('normalise.write.prefix') prefix];
  end

end

function [prefix, motionRegressorPrefix] = prefixForFFX(opt, prefix, funcFWHM)

  motionRegressorPrefix = prefixForSTC(prefix, opt);

  prefix = getPrefix('smooth', opt);

  if funcFWHM > 0
    prefix = [spm_get_defaults('smooth.prefix') num2str(funcFWHM) prefix];
  end

end
