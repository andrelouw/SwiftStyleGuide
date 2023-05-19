# SwiftStyle
> ⚠️ This project is still under active development and breaking changes is a guarantee. 😱

A linter and formatter using [SwiftLint](https://github.com/realm/SwiftLint/tree/main) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) to enforce code styling.
The idea is to have a stand-alone swift package to enforce a team's code styling, by using linting and formatting.
The idea came from [Airbnb Swift Style Guide](https://github.com/airbnb/swift) and aims to take their existing approach just one step further.


## Running executable
```bash
swiftstyle --swift-format-path /opt/homebrew/bin/swiftformat --swift-format-config default.swiftformat --swift-lint-path /opt/homebrew/bin/swiftlint --swift-lint-config swiftlint.yml .
``` 

During development run:
```bash
swift run swiftstyle
```
## Adding package to Xcode
Add the package to Xcode as with any other swift package *BUT* don't add it to the project. i.e. don't add it the targets, this will cause unexpected errors.

## Build Plugin
To run `swiftstyle` for each build in Xcode add it as a `Build Tool Plugin` under `Build Phases`. `StyleSwift` will then run on each build.  

## Command Plugin
> TODO: Documentation

## Releasing a build
- Update `Makefile` with version
- Run `make`
- Copy `checksum` from above command and paste in `Package.swift` under binary target `SwiftStyleBinary`
- Bump version in `url` in `Package.swift` under binary target `SwiftStyleBinary`
- Commit changes and push
- Create new release on Github matching new version in `Makefile`
- Upload `swiftstyle.artifactbundle.zip` as resource to the release

> NOTES:
> - Refer to script at https://github.com/nicklockwood/SwiftFormat/blob/7ff506897aa5bdaf94f077087a2025b9505da112/Scripts/spm-artifact-bundle.sh

## Roadmap
See issues for outstanding features/tasks

## References
- https://github.com/mac-cain13/R.swift
- https://github.com/MarcoEidinger/SwiftFormatPlugin
- https://github.com/nicklockwood/SwiftFormat
- https://github.com/realm/SwiftLint
- https://theswiftdev.com/introduction-to-spm-artifact-bundles/
- https://github.com/airbnb/swift
