return {
    {
        "rebelot/kanagawa.nvim",
        priority = 100,
        -- Prevent lazy loading when specified as a dependency
        lazy = false,
        opts = {
            transparent = true
            -- Use a darker theme
            -- background = {dark = "dragon"}
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)

            vim.cmd.colorscheme("kanagawa")
        end
    }, {
        "nvim-treesitter/nvim-treesitter",
        main = "nvim-treesitter.configs",
        build = ":TSUpdate",
        opts = {
            highlight = {enable = true},
            indent = {enable = true},
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    scope_incremental = false,
                    node_incremental = "<CR>",
                    node_decremental = "<S-CR>"
                }
            },
            ensure_installed = {
                "rust", "toml", "cpp", "c", "zig", "python", "lua", "fsharp", "javascript",
                "typescript", "json", "css", "html"
            }
        }
    }, {
        "saghen/blink.cmp",
        -- Needed to load pre-built binaries
        tag = "v0.12.4",
        opts = {
            -- Disable suggestions in command mode
            cmdline = {enabled = false},
            completion = {
                list = {selection = {auto_insert = false}},
                documentation = {auto_show = true, auto_show_delay_ms = 0, update_delay_ms = 0}
                -- A bit weird
                -- ghost_text = {enabled = true}
            },
            -- Accepting with space could be more convenient
            keymap = {
                preset = "none",
                ["<M-k>"] = {"select_prev"},
                ["<M-j>"] = {"select_next"},
                ["<M-l>"] = {"accept"}
            },
            sources = {default = {"lsp", "path", "snippets", "buffer"}}
        }
    }, {"neovim/nvim-lspconfig"}, {
        "dundalek/lazy-lsp.nvim",
        dependencies = {"neovim/nvim-lspconfig", "saghen/blink.cmp"},
        opts = function()
            return {
                excluded_servers = {
                    "ccls", -- Prefer clangd
                    "ltex", -- Heavy CPU usage
                    "tailwindcss" -- Associates with too many filetypes
                },
                -- Each key is a filetype (automatically detected by Neovim)
                -- lspconfig defines the filetypes supported by a server
                preferred_servers = {
                    python = {"basedpyright", "ruff"},
                    lua = {"lua_ls"},
                    javascript = {"biome"},
                    typescript = {"biome"},
                    markdown = {}
                },
                default_config = {
                    flags = {debounce_text_changes = vim.opt.updatetime:get()},
                    capabilities = require("blink.cmp").get_lsp_capabilities()
                },
                configs = {
                    lua_ls = {
                        on_new_config = function(config, root_dir)
                            local nvim_root = vim.fn.expand("~/.config/nvim")

                            -- "Is root_dir not a descendant of nvim_root?"
                            if root_dir:sub(1, #nvim_root) ~= nvim_root then
                                return
                            end

                            config.settings.Lua = {
                                runtime = {version = "LuaJIT"},
                                workspace = {
                                    library = {vim.env.VIMRUNTIME}
                                    -- Might be too slow (pull all directories from rtp)
                                    -- library = vim.api.nvim_get_runtime_file("", true)
                                }
                            }
                        end
                    }
                }
            }
        end
    }, {"nvim-lua/plenary.nvim"}, {
        "theprimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"},
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)

            -- Control ignores case so we need to explicitly add shift
            vim.keymap.set("n", "<C-S-H>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-L>", function() harpoon:list():next() end)

            vim.keymap.set("n", "<C-`>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end)

            for num = 1, 9 do
                vim.keymap.set("n", "<C-" .. num .. ">", function()
                    harpoon:list():select(num)
                end)
            end

            vim.keymap.set("n", "<C-0>", function()
                local list = harpoon:list()
                list:select(list:length())
            end)
        end
    }, {
        "mbbill/undotree",
        init = function() vim.g.undotree_SetFocusWhenToggle = 1 end,
        config = function()
            -- Undotree is a Vimscript plugin; it doesn't have setup()

            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    }
}
