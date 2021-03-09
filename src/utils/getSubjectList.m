% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function opt = getSubjectList(BIDS, opt)

  allSubjects = bids.query(BIDS, 'subjects');

  % Whatever subject entered must be returned "linearized"
  tmp = opt.subjects;
  tmp = tmp(:);

  % if any group is mentioned
  if ~isempty(opt.groups{1}) && ...
          any(strcmpi({'group'}, fieldnames(BIDS.participants)))

    fields = fieldnames(BIDS.participants);
    fieldIdx = strcmpi({'group'}, fields);

    subjectIdx = strcmp(BIDS.participants.(fields{fieldIdx}), opt.groups);

    subjects = char(BIDS.participants.participant_id);
    subjects = cellstr(subjects(subjectIdx, 5:end));

    tmp = cat(1, tmp, subjects);

  end

  % If no subject specified so far we take all subjects
  if isempty(tmp) || iscell(tmp) && isempty(tmp{1})
    tmp = allSubjects;
  end

  % remove duplicates
  opt.subjects = unique(tmp);

  if size(opt.subjects, 1) == 1
    opt.subjects = opt.subjects';
  end

  % check that all the subjects asked for exist
  if any(~ismember(opt.subjects, allSubjects))
    fprintf('subjects specified\n');
    disp(opt.subjects);
    fprintf('subjects present\n');
    disp(allSubjects);

    errorStruct.identifier = 'getSubjectList:noMatchingSubject';
    errorStruct.message = 'Some of the subjects specified do not exist in this data set.';
    error(errorStruct);
  end

end
