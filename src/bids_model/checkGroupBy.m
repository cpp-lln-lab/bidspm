function [status, groupBy] = checkGroupBy(node)
  %
  % Only certain type of GroupBy supported for now for each level
  %
  % This helps doing some defensive programming
  %

  % (C) Copyright 2022 bidspm developers

  status = true;
  groupBy = sort(node.GroupBy);

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

      % only certain type of GroupBy supported for now
      if numel(groupBy) > 2 || ~all(ismember(lower(groupBy), {'contrast', 'group'}))

        status = false;

        supportedGroupBy = {'["contrast"]', '["contrast", "group"]'};

      end

  end

  if ~status
    template = 'only "GroupBy": %s supported %s node level';
    msg = sprintf(template, ...
                  bids.internal.create_unordered_list(supportedGroupBy), ...
                  node.Level);
    notImplemented(mfilename(), msg);
  end

end
