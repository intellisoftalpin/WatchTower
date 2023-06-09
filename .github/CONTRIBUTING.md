# For contributors

## Introduction

Thank you for your interest to contribute to **Watch Tower** project!

You can help us with the following:
- New features
- Bug fixes
- Refactoring
- Unit tests
- UI tests
- Documentation improvements
- Bug reports
- Feature requests

To start you can check [open issues](https://github.com/intellisoftalpin/WatchTower/issues) and 
choose a preferred work. You can also create your own
[bug reports](https://github.com/intellisoftalpin/WatchTower/issues/new?assignees=&labels=bug&template=bug_report.md&title=) 
or [feature requests](https://github.com/intellisoftalpin/WatchTower/issues/new?assignees=&labels=feature&template=feature_request.md&title=).

Ask repository owner to add you to contributors list.

## Code rules

- All secrets and sensitive content must be stored in separate files and added to [.gitignore](https://github.com/intellisoftalpin/WatchTower/blob/main/.gitignore).
- If the current version is released, a new one should be provided in [VERSION](https://github.com/intellisoftalpin/WatchTower/blob/develop/VERSION) file.
- Unit-tests are welcome, especially for the logic parts.
- During code writing don't forget to make [documentation comments](https://dart.dev/effective-dart/documentation).

## Repository

### Branches

Branches **must be** created from [develop](https://github.com/intellisoftalpin/WatchTower/tree/develop) branch. 
Direct pushes to **develop** and **main** are not allowed.

Name conventions for branches:

```
[feature/bug/update]/[#issue_number-branch-name]
```

Examples:

```
bug/#123-app-settings-crash
update/docs-resources
feature/new-page
feature/#41-new-feature
```

### Commits

Name conventions for commits:

```
[ADD/DELETE/UPDATE/FIX] [#ISSUE_NUMBER] Description
```

Examples:

```
[FIX] [#123] App settings crash
[UPDATE] Docs resources
[ADD] New page
[ADD] [#41] New feature
```

### Pull requests

Before submitting pull request you should choose the reviewer.  
The following checks should pass:

- [GitHub Actions](https://github.com/intellisoftalpin/WatchTower/actions)
- Reviewer check

Name conventions for pull request titles are the same as for [commits](#commits).
