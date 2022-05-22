function status = checkGroupBy(node)
  %
  % Only certain type of GroupBy supported for now for each level
  %
  % This helps doing some defensive programming
  %
  % (C) Copyright 2022 CPP_SPM developers

  status = true;
  node.GroupBy = sort(node.GroupBy);

  switch lower(node.Level)

    case 'run'

      % only certain type of GroupBy supported for now
      if strcmp(node.GroupBy{1}, 'run') && ...
          ~all(ismember(node.GroupBy, {'run', 'session', 'subject'}))

        status = false;

        supportedGroupBy = {'["run", "subject"]', '["run", "session", "subject"]'};

      end

    case 'subject'

      if not(all([strcmp(node.GroupBy{1}, 'contrast') strcmp(node.GroupBy{2}, 'subject')]))
        
        status = false;
        
        supportedGroupBy = {'["contrast", "subject"]', '["run", "session", "subject"]'};

      end
      
    case 'dataset'
      
      % only certain type of GroupBy supported for now
      if numel(node.GroupBy) > 1 &&  ~all(ismember(node.GroupBy, {'contrast'}))
        
        status = false;
        
        supportedGroupBy = {'["contrast"]'};
        
      end

  end

  if ~status
    template = 'only "GroupBy": %s supported %s node level';
    msg = sprintf(template, createUnorderedList(supportedGroupBy), node.Level);
    notImplemented(mfilename(), msg, true);
  end

end
