if vim.fn.getenv("XDG_SESSION_TYPE") ~= "wayland" then
    return
end

-- Yank to Wayland clipboard when appropriate
local function WLYank(event)
    local regname = event.regname or ""
    local cb = vim.o.clipboard
    if regname:match("[+*]") or cb:match("<unnamed(plus)?>") then
        vim.fn.system("wl-copy", vim.fn.getreg("@"))
    end
end

-- Paste from Wayland clipboard
local function WLPaste(pasteCmd)
    local text = vim.fn.systemlist("wl-paste --no-newline")
    vim.fn.setreg("@", table.concat(text, "\n"))
    -- Perform the paste
    vim.cmd('normal! ""' .. pasteCmd)
end

-- Autocommand for yanking
vim.api.nvim_create_augroup("WLYank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = "WLYank",
    callback = WLYank,
})

-- Determine if unnamedplus clipboard is enabled
local unnamed_plus = vim.o.clipboard:match("<unnamed(plus)?>") ~= nil

local opts = { noremap = true, silent = true }

-- Normal and visual mappings for unnamed/Wayland clipboard
if unnamed_plus then
    vim.keymap.set("n", "p", function() WLPaste("p") end, opts)
    vim.keymap.set("n", "P", function() WLPaste("P") end, opts)
    vim.keymap.set("x", "p", function() WLPaste("p") end, opts)
    vim.keymap.set("x", "P", function() WLPaste("P") end, opts)
end

-- Explicit mappings for + and * registers
vim.keymap.set("n", '"+p', function() WLPaste("p") end, opts)
vim.keymap.set("n", '"+P', function() WLPaste("P") end, opts)
vim.keymap.set("n", '"*p', function() WLPaste("p") end, opts)
vim.keymap.set("n", '"*P', function() WLPaste("P") end, opts)
vim.keymap.set("x", '"+p', function() WLPaste("p") end, opts)
vim.keymap.set("x", '"+P', function() WLPaste("P") end, opts)
vim.keymap.set("x", '"*p', function() WLPaste("p") end, opts)
vim.keymap.set("x", '"*P', function() WLPaste("P") end, opts)

-- Insert-mode mappings
vim.keymap.set("i", "<C-r>+", function()
    WLPaste("p"); vim.cmd("normal! `]")
end, opts)
vim.keymap.set("i", "<C-r>*", function()
    WLPaste("p"); vim.cmd("normal! `]")
end, opts)

vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })
