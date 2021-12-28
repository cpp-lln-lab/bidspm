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
  % :param faa: optional argument. Lorem ipsum dolor sit amet,
  % :type faa: structure
  % :param fii: parameter. default: ``boo``
  % :type fii: string
  %
  % :returns: - :foo: (type) (dimension)
  %           - :faa: (type) (dimension)
  %           - :fii: (type) (dimension)
  %
  % Example::
  %
  % (C) Copyright 2021 CPP_SPM developers

  % The code goes below

  p = inputParser;

  default_faa = [];
  default_fii = 'boo';

  addRequired(p, 'foo', @iscell);
  addOptional(p, 'faa', default_faa, @isstruct);
  addParameter(p, 'fii', default_fii, @ischar);

  parse(p, varargin{:});

  foo = p.Results.foo;
  faa = p.Results.faa;
  fii = p.Results.fii;

  vargarout = {foo, faa, fii};

end
