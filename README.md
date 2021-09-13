<!-- lint disable -->

**Documentation**

[![Documentation Status: stable](https://readthedocs.org/projects/cpp_spm/badge/?version=stable)](https://cpp_spm.readthedocs.io/en/stable/?badge=stable)

**Code quality and style**
[![](https://img.shields.io/badge/Octave-CI-blue?logo=Octave&logoColor=white)](https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline/actions)
![](https://github.com/cpp-lln-lab/CPP_SPM/workflows/CI/badge.svg)

**Unit tests and coverage**
[![codecov](https://codecov.io/gh/Remi-Gau/CPP_SPM/branch/master/graph/badge.svg?token=8IoRQtbFUV)](https://codecov.io/gh/Remi-Gau/CPP_SPM)

**How to cite**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3556173.svg)](https://doi.org/10.5281/zenodo.3556173)

**Contributors**

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-8-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

<!-- lint enable -->

# CPP SPM

This is a set of functions to MRI analysis on a
[BIDS data set](https://bids.neuroimaging.io/) using SPM12.

## Installation

We strongly recommend using the CPP fMRI analysis template repository (INSERT
URL) to use CPP_SPM.

Download this repository and unzip the content where you want to install it.

Or clone the repo.

```bash
git clone --recurse-submodule https://github.com/cpp-lln-lab/CPP_SPM.git
```

Fire up Octave or Matlab and type

```matlab

cd CPP_SPM

% The following adds the relevant folders to your path.
% This needs to be done once per session (your path will not be saved)

initCppSpm()

```

Please see our
[documentation](https://cpp-spm.readthedocs.io/en/latest/index.html) for more
detailed instructions.

### Dependencies

Make sure that the following toolboxes are installed and added to the matlab
path.

For instructions see the following links:

<!-- lint disable -->

| Dependencies                                               | Used version |
| ---------------------------------------------------------- | ------------ |
| [Matlab](https://www.mathworks.com/products/matlab.html)   | 20???        |
| or [octave](https://www.gnu.org/software/octave/)          | 4.?          |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) | v7487        |

<!-- lint enable -->

## Features

This can perform:

-   slice timing correction,

-   spatial preprocessing:

    -   realignment, coregistration `func` to `anat`, `anat` segmentation,
        normalization to MNI space

    -   realignm and unwarp, coregistration `func` to `anat`, `anat`
        segmentation

-   smoothing,

-   Quality analysis:

    -   for anatomical data
    -   for functional data

-   GLM at the subject level

-   GLM at the group level à la SPM (meaning using a summary statistics
    approach).

The core functions are in the `src` folder.

Please see our
[documentation](https://cpp_spm.readthedocs.io/en/latest/index.html) for more
info.

## Octave compatibility

The following features do not yet work with Octave:

-   anatomicalQA
-   functionalQA
-   slice_display toolbox

## Contributing

Feel free to open issues to report a bug and ask for improvements.

If you want to contribute, have a look at our
[contributing guidelines](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md)
that are meant to guide you and help you get started. If something is not clear
or you get stuck: it is more likely we did not do good enough a job at
explaining things. So do not hesitate to open an issue, just to ask for
clarification.

### Style guidelines

These are some of the guidelines we try to follow.

We use `camelCase` to name functions and variables for the vast majority of the
code in this repository.

Scripts names in general and as well functions related to the demos use a
`snake_case`.

Constant are written in `UPPERCASE`.

#### Pre-commit

There is a [pre-commit hook](https://pre-commit.com/) that you can use to
reformat files as you commit them.

Install pre-commit by using our `requirements.txt` file

```bash
pip install -r requirements.txt
```

Install the hook

```bash
pre-commit install
```

You're done. `mh_style --fix` will now be run every time you commit.

## Contributors

Thanks goes to these wonderful people
([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/CerenB"><img src="https://avatars1.githubusercontent.com/u/10451654?v=4?s=100" width="100px;" alt=""/><br /><sub><b>CerenB</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3ACerenB" title="Bug reports">🐛</a> <a href="#content-CerenB" title="Content">🖋</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=CerenB" title="Documentation">📖</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=CerenB" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3ACerenB" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/fedefalag"><img src="https://avatars2.githubusercontent.com/u/50373329?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Fede F.</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Afedefalag" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/mwmaclean"><img src="https://avatars.githubusercontent.com/u/54547865?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Michèle MacLean</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=mwmaclean" title="Code">💻</a> <a href="#ideas-mwmaclean" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/mohmdrezk"><img src="https://avatars2.githubusercontent.com/u/9597815?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mohamed Rezk</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=mohmdrezk" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3Amohmdrezk" title="Reviewed Pull Requests">👀</a> <a href="#design-mohmdrezk" title="Design">🎨</a></td>
    <td align="center"><a href="https://cpplab.be"><img src="https://avatars0.githubusercontent.com/u/55407947?v=4?s=100" width="100px;" alt=""/><br /><sub><b>OliColli</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=OliColli" title="Code">💻</a> <a href="#design-OliColli" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=OliColli" title="Documentation">📖</a></td>
    <td align="center"><a href="https://remi-gau.github.io/"><img src="https://avatars3.githubusercontent.com/u/6961185?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Remi Gau</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Code">💻</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Documentation">📖</a> <a href="#infra-Remi-Gau" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#design-Remi-Gau" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3ARemi-Gau" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3ARemi-Gau" title="Bug reports">🐛</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=Remi-Gau" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/anege"><img src="https://avatars0.githubusercontent.com/u/50317099?v=4?s=100" width="100px;" alt=""/><br /><sub><b>anege</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=anege" title="Code">💻</a> <a href="#design-anege" title="Design">🎨</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/marcobarilari"><img src="https://avatars3.githubusercontent.com/u/38101692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>marcobarilari</b></sub></a><br /><a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Code">💻</a> <a href="#design-marcobarilari" title="Design">🎨</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/pulls?q=is%3Apr+reviewed-by%3Amarcobarilari" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Documentation">📖</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/commits?author=marcobarilari" title="Tests">⚠️</a> <a href="https://github.com/cpp-lln-lab/CPP_SPM/issues?q=author%3Amarcobarilari" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the
[all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
