# Running the jupyter notebooks with Octave and SPM

1.  Make sure that you have Octave installed.

1.  Make sure that SPM has been recompiled to be used with Octave

    ```
    SPM_path=???
    cd ${SPM_path}/src
    make PLATFORM=octave
    make PLATFORM=octave install
    ```

1.  If you have Conda or pip installed jupyter notebook or jupyter lab, skipt
    the next step. To check if Conda is installed properly: type `conda list`
    into your terminal.

1.  Download the
    [Anaconda Installer](https://www.anaconda.com/products/individual) and
    install it. If using miniconda, run `conda install jupyter` to download and
    install the Jupyter Notebook package.

1.  Install [Octave kernel](https://pypi.org/project/octave-kernel/):
    `pip install octave_kernel`. If you have already run
    `pip install .[demo]`, you should be fine.

1.  Run `jupyter lab` or `jupyter notebook` in your terminal. `Octave` should
    appear on the list of kernels available for creating a new notebook.
