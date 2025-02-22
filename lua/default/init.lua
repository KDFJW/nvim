require("default.config")
require("default.keymaps")

local common = require("default.common")

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local has_lazy = vim.uv.fs_stat(lazy_path)

coroutine.wrap(function()
    local exit_code, stderr = 0, ""

    if not has_lazy then
        local co = coroutine.running()

        common.shell("git", {
            "clone", "--filter=blob:none", "--branch=stable",
            "https://github.com/folke/lazy.nvim.git", lazy_path
        }, function(...) coroutine.resume(co, ...) end)

        exit_code, _, _, stderr = coroutine.yield()
    end

    vim.schedule(function()
        local failure = exit_code ~= 0

        if stderr ~= "" then
            local highlight = "WarningMsg"

            if failure then
                stderr = "Failed to clone lazy.nvim:\n" .. stderr
                highlight = "ErrorMsg"
            end

            vim.api.nvim_echo({{stderr, highlight}}, true, {})
        end

        if failure then return end

        vim.opt.rtp:prepend(lazy_path)

        require("lazy").setup({
            spec = {{import = "default.plugins"}},
            -- Automatically check for plugin updates
            checker = {enabled = true},
            change_detection = {enabled = false, notify = false}
        })
    end)
end)()
