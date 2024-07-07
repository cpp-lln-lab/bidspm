from __future__ import annotations


def matlab() -> str:
    r"""Return the path to the Matlab executable.

    Modify this value to match your Matlab installation.

    The MATLAB 'matlabroot' should tell you where MATLAB is installed.

    The 'matlab' executable is usually in the 'bin' subdirectory.

    -   Windows: ``'C:\\Program Files\\MATLAB\\R20XXx\bin\\matlab.exe'``
    -   Mac: ``'/Applications/Matlab_R20XXx.app/bin/matlab'``
    -   Linux: ``'/usr/local/MATLAB/R20XXx/bin/matlab'``
    """
    return "/usr/local/MATLAB/R2018a/bin/matlab"
