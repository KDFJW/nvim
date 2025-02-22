local common = require("default.common")

local function format_current_file()
    local buf = vim.api.nvim_get_current_buf()

    for option, preserving in pairs({modifiable = false, readonly = true}) do
        if vim.api.nvim_get_option_value(option, {buf = buf}) == preserving then
            return
        end
    end

    local commands = {
        [{"rust"}] = "rustfmt --edition 2021",
        [{"c", "cpp"}] = "clang-format --style=file -i",
        [{"zig"}] = "zig fmt",
        [{"python"}] = "black",
        [{"lua"}] = "lua-format -i",
        [{"fsharp"}] = "fantomas --force",
        [{"javascript", "typescript"}] = "prettier --write --tab-width 4"
    }

    local bin, args
    for filetypes, command in pairs(commands) do
        for _, filetype in ipairs(filetypes) do
            if filetype == vim.bo.filetype then
                bin, args = common.parse_call(command)
            end
        end
    end

    local path = vim.api.nvim_buf_get_name(buf)
    local success

    local timeout_ms = 1000

    -- An empty string means no associated file
    if bin and path ~= "" then
        table.insert(args, path)

        local exit_code, stderr
        local done = false

        local _, process = common.shell(bin, args, function(...)
            exit_code, _, _, stderr = ...
            done = true
        end)

        local prefix = string.format("[%s] ", bin)

        if vim.wait(timeout_ms, function() return done end) then
            -- Reload the active buffer to show changes to the file
            vim.cmd.checktime()

            success = exit_code == 0

            if stderr ~= "" then
                local highlight = not success and "ErrorMsg" or "WarningMsg"
                vim.api.nvim_echo({{prefix .. stderr, highlight}}, true, {})
            end
        else
            process.handle:kill()

            vim.api.nvim_echo({{prefix .. "timeout", "WarningMsg"}}, true, {})
        end
    else
        local function get_tick()
            return vim.api.nvim_buf_get_var(buf, "changedtick")
        end

        local last_tick = get_tick()

        vim.lsp.buf.format({timeout_ms = timeout_ms, bufnr = buf, range = nil})

        success = get_tick() ~= last_tick or nil
    end

    -- nil means we're unsure
    if success == nil then return end

    -- Should match :w but doesn't
    local relative_path = vim.fn.fnamemodify(path, ":~:.")
    local status = success and
                       string.format('"%s" %dL, %dB formatted', relative_path,
                                     vim.api.nvim_buf_line_count(0),
                                     vim.fn.getfsize(path)) or
                       string.format('Unable to format "%s"', relative_path)

    local highlight = not success and "ErrorMsg" or nil
    vim.api.nvim_echo({{status, highlight}}, true, {})
end

-- Disable for being too easy to accidentally press
vim.keymap.set("n", "<S-CR>", "<NOP>")

-- Treat wrapped lines as if they actually occupied multiple rows
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", {expr = true})
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", {expr = true})

-- Simplified movement between windows
vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-k>", "<C-W>k")
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")

-- Fold the next line onto the current one
vim.keymap.set("n", "J", "mzJ`z")

-- Less jarring jumps to matching text
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Quick exit to netrw
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader><CR>", format_current_file)

-- cd into the directory of the active buffer
vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>:pwd<CR>")

-- Replace all instances of the word under cursor
vim.keymap.set("n", "<leader>s",
               [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
