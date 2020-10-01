# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Changed

- Internal: Encryptor can now use other ciphers than the default



## [0.3.3] - 2020-07-25

### Fixed

- Explicit FileUtils require to avoid potentially warning logs



## [0.3.2] - 2020-07-20

### Added

- CLI: `diffcrypt generate-key` command to generate a new key for a cipher
- Internal: Library now generates and publishes code coverage publically on Code Climate

### Changed

- Only support ruby 2.5+ since 2.4 is no longer maintained

### Removed

- No longer generate and store a checksum. Backwards compatible since it wasn't used



## [0.3.1] - 2020-07-08

### Fixed

- Thor deprecation error no longer shows on CLI failure

### Changed

- Thor 0.20+ can now be used alongside this gem



## [0.3.0] - 2020-06-30

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
