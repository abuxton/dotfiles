# Dotfiles

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

[![dotfiles cast](./assets/asciinema/dotfiles-session.gif)](./assets/asciinema/dotfiles-session.gif)

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
git clone https://github.com/abuxton/dotfiles.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

<!-- ### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/abuxton/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,.osx,LICENSE-MIT.txt}
```
 -->
To update later on,the boostrap commoand is aliased in $PATH `bootstrap`

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing

```bash
export PATH="/usr/local/bin:$PATH"
```

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this [.extras](./.extras) as I use a `.<name>_profile` to extend the idea and contain sprawl.

```bash
...
if [ -f ~/.github_profile ]; then
    #     echo "github!"
    source ~/.github_profile
fi
if [ -f ~/.gcloud_profile ]; then
    #     echo "gcloud!"
    source ~/.gcloud_profile
fi
if [ -f ~/.vscode_profile ]; then
    #     echo "vscode!"
    source ~/.vscode_profile
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/abuxton/dotfiles/fork) instead, though.

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
# currently excluded
./.macos
```

### Install Homebrew formulae

When setting up a new Mac, you may want to install some common [Homebrew](https://brew.sh/) formulae (after installing Homebrew, of course):
I go as far as using brew dump and an external homebrew repo for this <https://github.com/abuxton/homebrew-brewfile>[![Awesome](https://awesome.re/badge.svg)](https://awesome.re) .

```bash
# currently excluded
./brew.sh
```

Some of the functionality of these dotfiles depends on formulae installed by `brew.sh`. If you don’t plan to run `brew.sh`, you should look carefully through the script and manually install any particularly important ones. A good example is Bash/Git completion: the dotfiles use a special version from Homebrew.

## Feedback

Suggestions/improvements
[welcome](https://github.com/abuxton/dotfiles/issues)!

## Author

- Adam Buxton
- <https://github.com/abuxton>
- `npx digitaladept`


## Thanks to…

* forked from [Mathias Bynens](https://mathiasbynens.be/)
* <https://github.com/abuxton/awesome-dotfiles> [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
