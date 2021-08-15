function list = createUnorderedList(list)
  %
  % turns a cell string into a string that is an unordered list to print to
  % the screen
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  list = sprintf(['\n\t- ', strjoin(list, '\n\t- '), '\n']);
end
