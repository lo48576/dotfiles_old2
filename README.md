# dotfiles management utilities

## Config
Write `/profile` file to specify which files to deploy (and to be feedbacked).

For example, if you want to use `/files/foo` and `/files/bar`, write `/profile` as below:

```
foo
bar
```

If files with same path exists in multiple directories, the last appeared file will overwrite the previous files.
(In the above example, if `/files/foo/home/.bazrc` and `/files/bar/home/.bazrc` exists, the latter is used.)

## Deploy
To copy files from `/files/` to the destination directories, run `/scripts/deploy.sh`.

## Feedback
To copy back files from destination directories to `/files/`, run `/scripts/feedback.sh`.
