## Contributing

Feel free to open issues to report a bug and ask for improvements.

If you want to contribute, have a look at our
[contributing guidelines](https://github.com/cpp-lln-lab/.github/blob/main/CONTRIBUTING.md)
that are meant to guide you and help you get started. If something is not clear
or you get stuck: it is more likely we did not do good enough a job at
explaining things. So do not hesitate to open an issue, just to ask for
clarification.

### Installation

To install bidspm and make changes to it, it is recommend to install the python
package in editable mode with all its development dependencies.

```bash
pip install -e .[dev]
```

### Initialisation

To facilitate running tests, make sure you initialize bidspm in dev mode, from
the MATLAB command line:

```matlab
bidspm dev
```

You can also run all the tests with:

```matlab
bidspm run_tests
```

### Style guidelines

We use `camelCase` to name functions and variables for the vast majority of the
code in this repository.

Scripts names in general and as well functions related to the demos use a
`snake_case`.

Constant are written in `UPPERCASE`.

#### Input arguments ordering

From more general to more specific

`BIDS` > `opt` > `subject` > `session` > `run`

-   `BIDS` (output from `getData` or `bids.layout`) restrict the set of possible
    analysis one can run to this BIDS data set
-   `opt` restricts this set even further
-   `subject` / `session` / `run` even more

```matlab
% OK
varargout = getInfo(BIDS, opt, subLabel, info, varargin)

% not OK
varargout = getInfo(subLabel, BIDS, opt, info, varargin)
```

#### Output arguments ordering

Try to return them in order of importance first and in order of appearance
otherwise.

#### Exceptions

If function creates or modifies a batch then `matlabbatch` is the first `argin`
and first `argout`.

If a function performs an "action" to be chosen from a one of several strings
(with a switch statement), this string comes as first `argin` or second if
`matlabbatch` is first.

```matlab
% OK
varargout = getInfo('filename', BIDS, opt, subID, varargin)
[matlabbatch, voxDim] = setBatchRealign(matlabbatch, [action = 'realign',] BIDS, opt, subID)

% not OK
% 'filename' is the name of the "action" or the info to get in this case
% batch and action should go first
varargout = getInfo(BIDS, opt, subID, 'filename', varargin)
[matlabbatch, voxDim] = setBatchRealign(BIDS, opt, subID, matlabbatch, [action = 'realign'])
```

### Updating the FAQ

The FAQ is rendered with FAQtory.

New questions must be added to `docs/questions` and the main FAQ.md can be
created with:

```bash
make update_faq
```

### release protocol

- [ ] create a dedicated branch for the release candidate
- [ ] update version in `citation.cff`
- [ ] documentation related
  - [ ] ensure the documentation is up to date
  - [ ] make sure the doc builds correctly and fix any error
- [ ] update jupyter books
- [ ] update binder
- [ ] update docker recipes
- [ ] update changelog
- [ ] run `make release`
- [ ] open a pull request (PR) from this release candidate branch targeting the default branch
- [ ] fix any remaining failing continuous integration (test, markdown and code linting...)
- [ ] merge to default branch
- [ ] create a tagged release
- [ ] build and push docker images if necessary
- [ ] after release
  - [ ] set version in `citation.cff` to dev
