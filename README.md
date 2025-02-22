# My Neovim configuration

Strives to do *the bare minimum*. The said minimum is contained within the
`default` module, which is automatically loaded

| Feature                                                    | Package           | Requirements                                       |
|------------------------------------------------------------|-------------------|----------------------------------------------------|
| Preferred values for built-in globals                      | -                 | -                                                  |
| Package manager                                            | `lazy.nvim`       | Neovim >= 0.8.0 (built with LuaJIT), Git >= 2.19.0 |
| 3 (three) color schemes                                    | `kanagawa.nvim`   | Latest Neovim, terminal with truecolor support     |
| Syntax-based highlighting, indentation, and text selection | `nvim-treesitter` | A C compiler,[^1] `libstdc++`, Git                 |
| Automatic management of language servers                   | `lazy-lsp.nvim`   | Nix                                                |
| Autocomplete                                               | `blink.cmp`       | Neovim >= 0.10.0, cURL, Git                        |
| Formatting                                                 | -                 | -[^2]                                              |
| Quick navigation                                           | `harpoon`         | Neovim >= 0.8.0                                    |
| Interactive edit history                                   | `undotree`        | -                                                  |

If you had a configuration before, it can interfere with the new one. This can
be fixed by removing the residual files:

```
rm -fr ~/.local/share/nvim ~/.cache/nvim
```

**Licensed under CC0**

[^1]: Multiple common compilers are tried

[^2]: All custom code assumes that the plugins' requirements are met
