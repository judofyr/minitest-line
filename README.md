# minitest-line

A Minitest 5 plugin for running focused tests.

```Bash
gem install minitest-line
ruby test/my_file -l 5
```

If you want to be able to run describe block by line number add
```Ruby
require 'minitest/line/describe_track'
```

## Acknowledgments

This plugin was inspired by [James Mead](https://github.com/floehopper) pull request to Minitest: [Run a test by line number from the command line (a.k.a. "run focussed test")](https://github.com/seattlerb/minitest/pull/267)

