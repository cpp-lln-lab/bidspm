Contributing
************

How to contribute to this project. 


Function templates
==================

.. automodule:: src.templates

Template proposal
-----------------

::

   % (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

   function [argout1, argout2] = templateFunction(argin1, argin2, argin3)
      %
      % Short description of what the function does goes here.
      %
      % USAGE::
      %
      %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
      %
      % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
      %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
      % :type argin1: type
      % :param argin2: optional argument and its default value. And some of the
      %               options can be shown in litteral like ``this`` or ``that``.
      % :type argin2: string
      % :param argin3: (dimension) optional argument
      %
      % :returns: - :argout1: (type) (dimension)
      %           - :argout2: (type) (dimension)
      %
      % .. todo:
      %
      %    - item 1
      %    - item 2

      % The code goes below

   end

.. autofunction:: templateFunction  


----

Numpy template
--------------

See more information `here 
<https://www.sphinx-doc.org/en/master/usage/extensions/example_numpy.html#example-numpy>`_

::

   function [argout] = templateFunction(argin1, argin2, argin3)
      %
      % Short description of what the function does goes here.
      %
      %  y = templateFunction(argin1, argin2, argin3)
      %
      % Parameters:
      %    argin1: The first input value
      %
      %    argin2: The second input value
      %
      %    argin3: The third input value 
      %
      % Returns:
      %    The output value

      % The code goes below

   end

.. autofunction:: templateFunctionNumpy

----

Google template
---------------

See more information `there 
<https://www.sphinx-doc.org/en/master/usage/extensions/example_google.html>`_


Example code in the help section
--------------------------------

::

   % (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

   function templateFunctionExample()
      % This function illustrates a documentation test defined for MOdox.
      % Other than that it does absolutely nothinghort description of what 
      % the function does goes here. 
      % 
      % Examples:
      %   a=2;
      %   disp(a)
      %   % Expected output is prefixed by '%||' as in the following line:
      %   %|| 2
      %   %
      %   % The test continues because no interruption through whitespace,
      %   % as the previous line used a '%' comment character;
      %   % thus the 'a' variable is still in the namespace and can be 
      %   % accessed.
      %   b=3+a;
      %   disp(a+[3 4])
      %   %|| [5 6]
      %
      %   % A new test starts here because the previous line was white-space
      %   % only. Thus the 'a' and 'b' variables are not present here anymore.
      %   % The following expression raises an error because the 'b' variable
      %   % is not defined (and does not carry over from the previous test).
      %   % Because the expected output indicates an error as well, 
      %   % the test passes
      %   disp(b)
      %   %|| error('Some error')
      %
      %   % A set of expressions is ignored if there is no expected output 
      %   % (that is, no lines starting with '%||').
      %   % Thus, the following expression is not part of any test,
      %   % and therefore does not raise an error.
      %   error('this is never executed)
      %
      %
      % % tests end here because test indentation has ended

      % The code goes below

.. autofunction:: templateFunctionExample



