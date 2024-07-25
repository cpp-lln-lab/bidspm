function [status, groupBy] = checkGroupBy(node, extraVar)
  %
  % Only certain type of GroupBy supported for now for each level
  %
  % This helps doing some defensive programming.
  %

  % (C) Copyright 2022 bidspm developers

  status = true;
  groupBy = sort(node.GroupBy);

  if nargin < 2
    extraVar = {};
  end

  switch lower(node.Level)

    case 'run'

      % only certain type of GroupBy supported for now
      if ~ismember('run', groupBy) || ...
          ~all(ismember(groupBy, {'run', 'session', 'subject'}))

        status = false;

        supportedGroupBy = {'["run", "subject"]', ...
                            '["run", "session", "subject"]'};

      end

    case 'session'

      if ~(numel(groupBy) == 3) || ...
          ~all(ismember(groupBy, {'contrast', 'session', 'subject'}))

        status = false;

        supportedGroupBy = {'["contrast", "session", "subject"]'};

      end

    case 'subject'

      if ~(numel(groupBy) == 2) || ...
          not(all([ismember('contrast', groupBy) ismember('subject', groupBy)]))

        status = false;

        supportedGroupBy = {'["contrast", "subject"]'};

      end

    case 'dataset'

      supportedGroupBy = { ...
                          '["contrast"]', ...
                          '["contrast", "x"] for "x" being a participant.tsv column name.'};

      % only certain type of GroupBy supported for now
      status = false;
      if numel(groupBy) == 1 && all(ismember(lower(groupBy), {'contrast'}))
        status = true;

      elseif numel(groupBy) == 2 && iscellstr(extraVar) && numel(extraVar) > 0
        for i = 1:numel(extraVar)
          if all(ismember(groupBy, {'contrast', extraVar{i}}))
            status = true;
            break
          end
        end

      end

  end

  if status
    return
  end

  template = 'only "GroupBy": %s supported %s node level';
  msg = sprintf(template, ...
                bids.internal.create_unordered_list(supportedGroupBy), ...
                node.Level);
  notImplemented(mfilename(), msg);

end
