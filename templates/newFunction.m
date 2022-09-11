function vargarout = newFunction(varargin)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [foo, faa, fi] = newFunction(foo, faa, fii, 'boo')
  %
  % :param foo: obligatory argument. Lorem ipsum dolor sit amet,
  % :type foo: cell
  %
  % :param faa: optional argument. Lorem ipsum dolor sit amet,
  % :type faa: structure
  %
  % :param fii: parameter. default: ``boo``
  % :type fii: string
  %
  % :returns: - :foo: (type) (dimension)
  %           - :faa: (type) (dimension)
  %           - :fii: (type) (dimension)
  %
  % Example::
  %
  % (C) Copyright 2022 bidspm developers

  % The code goes below

  args = inputParser;

  default_faa = [];
  default_fii = 'boo';

  addRequired(args, 'foo', @iscell);
  addOptional(args, 'faa', default_faa, @isstruct);
  addParameter(args, 'fii', default_fii, @ischar);

  parse(args, varargin{:});

  foo = args.Results.foo;
  faa = args.Results.faa;
  fii = args.Results.fii;

  vargarout = {foo, faa, fii};

end
