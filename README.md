# dotfiles management utilities

## Config
1. Write `/profiles/*` file to specify which files to deploy (and to be feedbacked) if necessary.
2. Create symlink to a file in `/profiles/` with link name `/profile`
   (for example, run `ln -s profiles/host-poyo profile` at repository root)

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
