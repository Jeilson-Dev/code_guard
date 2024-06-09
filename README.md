# Code Guard

Code Guard is an essential tool for developers aiming to maintain the quality and organization of their software projects.

This software automatically scans the source code for comments containing the terms "check", "todo", or "fix".

By identifying these terms, Code Guard generates detailed reports that help developers track and manage pending tasks, quality checks, and necessary fixes.

With Code Guard, code maintenance becomes more efficient and effective, ensuring that no important task is overlooked.

At end of Code Guard runner it will return a error to the terminal to inform that happens a error and block the followed actions, this protect you to proceed with a unfinished task.

## Getting started

### Install it

You can install the package from the command line:

```bash
    dart pub global activate code_guard
```

### Setup

After installed, create a new file in you project root named `check.yaml` and add the settings as example below:

> All these settings can be ignored, but it's recommended use some combinations for save you time since this tool will check all files, so we can ignore folders and filetypes.

```yaml
patterns: # this represents the pattern that we want found
  - "// fix:" # here when using special characters like colon ':' yaml will interpret this as a nested object so to avoid this we use double quoted patterns like these example
  - "// todo:"

targetFileTypes: # we can explicit the file type that we wish focus to ignore the others types if this is empty, check command will check all filetypes
  - dart

explicitIgnoreSubType: # we also can ignore subtypes like code generation files adding this here
  - .gen.dart
  - .freezed.dart

explicitIgnoreFolder: # this is very helpful to avoid look to unnecessary folders
  - /.dart_tool
  - /.git
```

## Run

From you root project run:

```bash
check
```

This will read the `yaml` file to get the settings and search for the patterns defined using the specified settings.

## Debug

To setup correctly the settings it was added a debug flag to print some helpful logs, to use debug option add the `-d` flag after the `check` command.

```bash
check -d
```

It will print the folders that are been scanned and the patterns found.

## Some usage

One case where it's helpful is when you are refactoring the code and you must avoid push commented code, so you can put a comment like `// fix: need fix this before push because ...` and run the `push` command with the `check` command first, like `check && git push`.

## Complete check.yaml example

```yaml
patterns:
  - "// fix:"
  - "// todo:"

targetFileTypes:
  - dart

explicitIgnoreSubType:
  - .gen.dart
  - .freezed.dart

explicitIgnoreFolder:
  - /.dart_tool
  - /.git
  - /.vscode
  - /.idea
  - /build
  - /android
  - /ios
  - /windows
  - /web
  - /linux
  - /macos
  - /.fvm
```
