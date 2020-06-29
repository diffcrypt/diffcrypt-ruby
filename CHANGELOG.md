# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).



## [Unreleased]

## Added

- CLI: Use diffcrypt from command line of any project without requiring ruby integration
- CLI: `diffcrypt encrypt` Directly encrypt any file and output the contents
- CLI: `diffcrypt decrypt` Directly decrypt any file and output the contents



## [0.2.0] - 2020-06-28

### Added

- Store client, cipher and checksum in file metadata

### Fixed

- Only attenpt to decrypt original content if it exists



## [0.1.1] - 2020-06-28

### Fixed

- Converting rails native credentials files would fail on first run



## [0.1.0] - 2020-06-28

### Added

- First release!
- Rails support via monkey patch
