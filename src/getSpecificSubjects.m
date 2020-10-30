% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function group = getSpecificSubjects(opt, group, iGroup, subjects)

  % add a test for ata set with subject only blind02 and we ask for this one
  % specifically

  % if no group or subject was specified we take all of them
  if numel(opt.groups) == 1 && ...
          strcmp(group(iGroup).name, '') && ...
          isempty(opt.subjects{iGroup})

    group(iGroup).subNumber = subjects;

    % if subject ID were directly specified by users we take those
  elseif strcmp(group(iGroup).name, '') && iscellstr(opt.subjects)

    group(iGroup).subNumber = opt.subjects;

    % if group was specified we figure out which subjects to take
  elseif ~isempty(opt.subjects{iGroup})

    idx = opt.subjects{iGroup};

    % else we take all subjects of that group
  elseif isempty(opt.subjects{iGroup})

    % count how many subjects in that group
    idx = sum(~cellfun(@isempty, strfind(subjects, group(iGroup).name)));
    idx = 1:idx;

  else

    error('Not sure what to do.');

  end

  % if only indices were specified we get the subject from that group with that
  if exist('idx', 'var')
    pattern = [group(iGroup).name '%0' num2str(opt.zeropad) '.0f_'];
    temp = strsplit(sprintf(pattern, idx), '_');
    group(iGroup).subNumber = temp(1:end - 1);
  end

end
