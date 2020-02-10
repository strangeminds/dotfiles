# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in $HOME/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Speed up runtime by caching this value
if command -v brew &> /dev/null; then
	BREW_PREFIX=$(brew --prefix)
else
	BREW_PREFIX=""
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Set options for Git bash completion
if [ -f "${BREW_PREFIX}/etc/bash_completion.d/git-completion.bash" ]; then
	# Set EnvVar so prompt displays Git status
	GIT_PS1_SHOWDIRTYSTATE=true
fi

# Add tab completion for many Bash commands
if command -v brew &> /dev/null && [ -r "${BREW_PREFIX}/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="${BREW_PREFIX}/etc/bash_completion.d";
	source "${BREW_PREFIX}/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Set up fzf
if [ -f "$HOME/.fzf.bash" ]; then
	# Setup fzf
	# ---------
	if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
		export PATH="$PATH:/usr/local/opt/fzf/bin"
	fi

	# Auto-completion
	# ---------------
	[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2> /dev/null

	# Key bindings
	# ------------
	source "/usr/local/opt/fzf/shell/key-bindings.bash"

	if [ -x "$BREW_PREFIX/bin/fd" ]; then
		# Use fd (https://github.com/sharkdp/fd) instead of the default find
		# command for listing path candidates.
		# - The first argument to the function ($1) is the base path to start traversal
		# - See the source code (completion.{bash,zsh}) for the details.
		_fzf_compgen_path() {
			fd --hidden --follow --exclude ".git" . "$1"
		}

		# Use fd to generate the list for directory completion
		_fzf_compgen_dir() {
			fd --type d --hidden --follow --exclude ".git" . "$1"
		}
	fi
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;

# Alias hub to git for GitHub CLI magic
if command -v hub &> /dev/null; then
	eval "$(hub alias -s)"
fi;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# Source SCM Breeze
[ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

# Generic Colouriser
if [ -f ${BREW_PREFIX}/etc/grc.bashrc ]; then
	. ${BREW_PREFIX}/etc/grc.bashrc
fi

# Enable aws-cli completion
if [ -f /usr/local/bin/aws_completer ]; then
	complete -C aws_completer aws
fi

# Enable rbenv shims and autocompletion
# github.com/sstephenson/rbenv/
if command -v rbenv &> /dev/null; then eval "$(rbenv init -)"; fi

# Enable pipenv completion
if [ -f ${BREW_PREFIX}/bin/pipenv ]; then
	eval "$(pipenv --completion)"
fi

# ChefDK binaries
# Added after rbenv to avoid path issues
PATH="/opt/chefdk/bin:$PATH"

# chef gem-installed binaries
PATH="$HOME/.chefdk/gem/ruby/2.6.0/bin:$PATH"

test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash
