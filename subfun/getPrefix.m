function [prefix, motionRegressorPrefix] = getPrefix(step,opt,degreeOfSmoothing)
% generates prefix to append to file name to look for

prefix = '';

switch step
   
    case 'STC'
        
    case 'preprocess'
        prefix = prefixForSTC(prefix, opt);

    case 'smoothing'
        prefix = prefixForSTC(prefix, opt);
        prefix = [spm_get_defaults('normalise.write.prefix') prefix];
  
    case 'FFX'
        prefix = prefixForSTC(prefix, opt);
        
        % for the motion regressors txt file
        motionRegressorPrefix = prefix;
        
        prefix = [spm_get_defaults('normalise.write.prefix') prefix];
        
        % Check which level of smoothing is applied
        if degreeOfSmoothing == 0       % If no smoothing applied, take the normalized data
        elseif degreeOfSmoothing > 0   % If the smoothing is applied, take the smoothed files
            prefix = [spm_get_defaults('smooth.prefix') num2str(degreeOfSmoothing) prefix];
        end
        
%     case 'MVPA'
%         prefix = prefixForSTC(prefix, opt);
%         
%         % for the motion regressors txt file
%         motionRegressorPrefix = prefix;
        
end



end



function prefix = prefixForSTC(prefix, opt)
% Check the slice timing information is not in the metadata and not added
% manually in the opt variable.
if (isfield(opt.metadata, 'SliceTiming') && ~isempty(opt.metadata.SliceTiming)) || ~isempty(opt.sliceOrder)
    prefix = [spm_get_defaults('slicetiming.prefix') prefix];
end
end