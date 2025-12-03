My zsh completion files.

- go.zsh - from https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/golang/golang.plugin.zsh edited to remove the silly `alias`s
- gh.zsh from `gh completion --shell zsh > ~/tm/dotfiles/zsh-completion/gh.zsh`
- gcloud from "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc" after `brew install --cask google-cloud-sdk`
- hx from "/opt/homebrew/Cellar/helix/25.07.1/share/zsh/site-functions" after `brew install helix`

Bad:

- rg.zsh is `complete/_rg` from a https://github.com/BurntSushi/ripgrep/releases tarball release
  Bad: removed because I get a warning from it that I don't grok:
    _arguments:comparguments:325: can only be called from completion function
