local function update_color_column()
    local limits = {
        [79] = {"python"},
        [80] = {"c", "cpp", "lua", "fsharp", "javascript", "typescript"},
        [100] = {"rust", "zig"}
    }

    for limit, filetypes in pairs(limits) do
        for _, filetype in ipairs(filetypes) do
            if filetype == vim.bo.filetype then
                -- In this case, opt_local is window-local
                vim.opt_local.colorcolumn = tostring(limit + 1)

                return
            end
        end
    end

    vim.opt_local.colorcolumn = ""
end

vim.opt.termguicolors = true -- Use truecolor
vim.g.netrw_banner = 0

vim.opt.nu = true -- Show line numbers
vim.opt.relativenumber = true -- Make line numbers relative to the cursor's position
vim.o.fillchars = "eob: " -- Hide ~ symbols on empty lines
vim.opt.signcolumn = "yes" -- Reserve space on the left for the LSP client

vim.opt.wrap = false -- Disable line wrapping

vim.opt.guicursor = "" -- Use block cursor in all modes

vim.opt.tabstop = 4 -- Width of tabs
vim.opt.shiftwidth = 0 -- Width of each indentation level (set to tabstop)
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = true -- Automatically indent new lines

vim.opt.scrolloff = 8 -- Buffers' scroll margin

vim.g.mapleader = " " -- Assign <leader> for key bindings
vim.opt.mouse = "" -- Disable mouse support

vim.opt.hlsearch = false -- Don't highlight search matches
vim.opt.incsearch = true -- Highlight matches as you type

vim.opt.updatetime = 400 -- Reduce delay for the CursorHold event

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- Directory for edit history
vim.opt.undofile = true -- Make edit history persist

vim.opt.swapfile = false
vim.opt.backup = false

vim.api.nvim_create_autocmd("BufWinEnter", {callback = update_color_column})
