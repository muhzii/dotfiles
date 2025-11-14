----------------------------------------------------------
-- General Settings
-----------------------------------------------------------
vim.g.mapleader = " "
-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local set = vim.opt
set.encoding = "utf-8"
set.number = true
set.relativenumber = true
set.backspace = { "indent", "eol", "start" }
set.wrap = false
set.scrolloff = 2
set.showcmd = true
set.ruler = true
set.laststatus = 2
set.autowrite = true
set.modeline = false
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.autoindent = true
set.expandtab = true
set.smarttab = true
set.incsearch = true
set.ignorecase = true
set.smartcase = true
set.hlsearch = true
set.emoji = true
set.cmdheight = 2
set.updatetime = 25
set.foldmethod = "syntax"
set.foldlevel = 5
set.ttimeout = true
set.ttimeoutlen = 10
set.splitbelow = true
set.splitright = true
set.clipboard = "unnamedplus"
set.termguicolors = true
set.hidden = true
set.autoread = true
set.wildmenu = true
set.showmatch = true
vim.o.mat = 2
set.colorcolumn = "81"
set.background = "dark"
vim.o.mouse = ""

-----------------------------------------------------------
-- Autocommands
-----------------------------------------------------------
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { command = "checktime" })
vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
vim.api.nvim_create_autocmd("BufWinEnter", { command = "match ExtraWhitespace /\\s\\+$/" })
vim.api.nvim_create_autocmd("InsertEnter", { command = "match ExtraWhitespace /\\s\\+\\%#\\@<!$/" })
vim.api.nvim_create_autocmd("InsertLeave", { command = "match ExtraWhitespace /\\s\\+$/" })
vim.api.nvim_create_autocmd("ColorScheme", { command = "highlight ExtraWhitespace ctermbg=red guibg=red" })
vim.api.nvim_create_autocmd("BufWinLeave", { command = "call clearmatches()" })
vim.api.nvim_create_autocmd("ColorScheme", { command = "highlight SpellBad guisp=#fabd2f" })

-----------------------------------------------------------
-- Colorscheme
-----------------------------------------------------------
vim.api.nvim_create_augroup("GitGutterColors", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = "GitGutterColors",
    pattern = "*",
    callback = function()
        vim.cmd("highlight GitGutterAdd guifg=#577857 ctermfg=65")
        vim.cmd("highlight GitGutterChange guifg=#567387 ctermfg=67")
        vim.cmd("highlight GitGutterDelete guifg=#656e76 ctermfg=102")
    end
})
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd("colorscheme gruvbox")

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
local map = vim.keymap.set
map("n", "<F3>", ":noh<CR>")
map("n", "<leader>-", ":wincmd _<CR>:wincmd |<CR>")
map("n", "<leader>=", ":wincmd =<CR>")
map("n", "<leader>j", "mz:m+<CR>`z")
map("n", "<leader>k", "mz:m-2<CR>`z")
map("v", "<leader>j", ":m'>+<CR>`<my`>mzgv`yo`z")
map("v", "<leader>k", ":m'<-2<CR>`>my`<mzgv`yo`z")
map("n", "<leader>b", ":Buffers<CR>")
map("n", "<leader>f", ":Files<CR>")
map("n", "<C-p>", ":Files<CR>")

-----------------------------------------------------------
-- Gitgutter
-----------------------------------------------------------
vim.g.gitgutter_sign_added = "▐"
vim.g.gitgutter_sign_modified = "▐"
vim.g.gitgutter_sign_removed = "▶"

-----------------------------------------------------------
-- Plugins (lazy.nvim)
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "tpope/vim-fugitive" },
    { "vim-python/python-syntax" },
    { "mileszs/ack.vim" },
    { "airblade/vim-gitgutter" },
    { "itchyny/lightline.vim" },
    { "tpope/vim-commentary" },
    { "tpope/vim-surround" },
    { "gregsexton/MatchTag" },
    { "christoomey/vim-tmux-navigator" },
    { "RyanMillerC/better-vim-tmux-resizer" },
    { "junegunn/fzf",                          build = function() vim.fn["fzf#install"]() end },
    { "junegunn/fzf.vim" },
    { "tpope/vim-unimpaired" },
    { "tpope/vim-vinegar" },
    { "tpope/vim-repeat" },
    { "muhzii/ReplaceWithRegister" },
    { "editorconfig/editorconfig-vim" },
    { "instant-markdown/vim-instant-markdown", ft = "markdown",                               build = "yarn install" },
    { "gruvbox-community/gruvbox" },

    -- Native LSP stack
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "L3MON4D3/LuaSnip",                      version = "v2.*",                              build = "make install_jsregexp" },
    { "rafamadriz/friendly-snippets" },
    { "saadparwaiz1/cmp_luasnip" },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false,
    },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal_cmd = nil,
            git_repo_cwd = true,
            terminal = {
                split_side = "right",
                split_width_percentage = 0.30,
                provider = "auto",
                auto_close = false,
            },
        },
        keys = {
            { "<leader>ac", "<cmd>ClaudeCode<CR>",           desc = "Toggle Claude Code" },
            { "<leader>as", "<cmd>ClaudeCodeSend<CR>",       mode = { "v" },             desc = "Send selection to Claude" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",      desc = "Add current buffer" },
            { "<leader>af", "<cmd>ClaudeCodeTreeAdd<cr>",    desc = "Add file",          ft = { "neo-tree" } },
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
        }
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    }
})

-----------------------------------------------------------
-- LSP, Completion, and Formatting
-----------------------------------------------------------
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspconfig_util = require("lspconfig.util")

-- Mason setup
mason.setup()
mason_lspconfig.setup({
    ensure_installed = {
        "pyright", "ts_ls", "gopls", "eslint", "bashls",
        "html", "cssls", "jsonls", "lua_ls", "efm"
    },
})

-- Completion setup
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<Esc>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.abort()
            end
            if luasnip.expand_or_jumpable() then
                luasnip.unlink_current()
            end
            fallback()
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    }),
})

-- LSP on_attach function
vim.keymap.del("n", "gri") -- remove default mapping in _default.lua
local on_attach = function(client, bufnr)
    local buf_map = function(mode, lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
    end
    buf_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    buf_map("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    buf_map("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
    buf_map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    buf_map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    buf_map("n", "<leader>r", "<cmd>lua vim.lsp.buf.rename()<CR>")

    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end,
        })
    end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Modern LSP setup (Neovim 0.11+)
local servers = {
    "pyright", "ts_ls", "eslint", "ccls", "gopls", "efm",
    "bashls", "html", "cssls", "jsonls", "lua_ls"
}
for _, server in ipairs(servers) do
    vim.lsp.config(server, {
        on_attach = on_attach,
        capabilities = capabilities,
    })
    vim.lsp.enable(server)
end

-- Manual C/C++ server (ccls)
vim.lsp.config("ccls", {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "ccls", "-v=2" },
    filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp", "h" },
    root_markers = { ".ccls", "compile_commands.json", ".git", ".hg" },
    init_options = {
        clang = {
            excludeArgs = {
                "-mno-fp-ret-in-387", "-mpreferred-stack-boundary=3",
                "-mskip-rax-setup", "-mindirect-branch=thunk-extern",
                "-mindirect-branch-register", "-fno-allow-store-data-races",
                "-fzero-call-used-regs=used-gpr", "-fconserve-stack",
                "-fplugin-arg-structleak_plugin-byref-all", "-falign-jumps=1",
                "-falign-loops=1", "-mrecord-mcount",
                "-fplugin=./scripts/gcc-plugins/structleak_plugin.so",
                "-DSTRUCTLEAK_PLUGIN",
            },
        },
        client = { snippetsSupport = true },
        cache = { directory = "/tmp/ccls" },
    },
})

vim.lsp.config("gopls", {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
                nilness = true,
                shadow = true,
            },
            staticcheck = true,
            usePlaceholders = true,
            completeUnimported = true,
            experimentalPostfixCompletions = true,
        }
    },
})

vim.lsp.config("efm", {
    init_options = { documentFormatting = true, codeAction = true },
    root_markers = { ".git", "." },
    filetypes = { "javascript", "typescript", "python", "go", "sh", "c", "cpp" },
    settings = {
        languages = {
            javascript = {
                { formatCommand = "prettier --stdin-filepath ${INPUT}",             formatStdin = true },
                { lintCommand = "eslint -f unix --stdin --stdin-filename ${INPUT}", lintStdin = true,  lintFormats = { "%f:%l:%c: %m" } },
            },
            typescript = {
                { formatCommand = "prettier --stdin-filepath ${INPUT}",             formatStdin = true },
                { lintCommand = "eslint -f unix --stdin --stdin-filename ${INPUT}", lintStdin = true,  lintFormats = { "%f:%l:%c: %m" } },
            },
            python = {
                { formatCommand = "autopep8 -",                           formatStdin = true },
                { lintCommand = "flake8 --stdin-display-name ${INPUT} -", lintStdin = true,  lintFormats = { "%f:%l:%c: %m" } },
            },
            go = {
                { formatCommand = "gofmt",     formatStdin = true },
                { formatCommand = "goimports", formatStdin = true },
                { lintCommand = "staticcheck", lintStdin = false, lintFormats = { "%f:%l:%c: %m" } },
            },
            sh = {
                { formatCommand = "shfmt -i 2 -ci",    formatStdin = true },
                { lintCommand = "shellcheck -f gcc -", lintStdin = true,  lintFormats = { "%f:%l:%c: %m" } },
            },
            c = {
                { formatCommand = "clang-format", formatStdin = true },
            },
            cpp = {
                { formatCommand = "clang-format", formatStdin = true },
            },
        },
    },
    on_attach = on_attach,
})

vim.lsp.enable('clangd', false)

-----------------------------------------------------------
-- Diagnostics
-----------------------------------------------------------
vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
        },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
})

-- Show undercurls
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = '#ff5555' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = '#f1fa8c' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = '#8be9fd' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = '#50fa7b' })

-- Show all diagnostics for current line in quickfix list
function ShowLineDiagnosticsInQuickfix()
    local bufnr = vim.api.nvim_get_current_buf()
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diags = vim.diagnostic.get(bufnr, { lnum = line })

    if vim.tbl_isempty(diags) then
        return
    end

    -- Convert diagnostics to quickfix items
    local items = {}
    for _, d in ipairs(diags) do
        table.insert(items, {
            bufnr = bufnr,
            lnum = d.lnum + 1,
            col = d.col + 1,
            text = string.format("[%s] %s", vim.diagnostic.severity[d.severity], d.message),
            type = ({
                [vim.diagnostic.severity.ERROR] = "E",
                [vim.diagnostic.severity.WARN]  = "W",
                [vim.diagnostic.severity.INFO]  = "I",
                [vim.diagnostic.severity.HINT]  = "H",
            })[d.severity],
        })
    end

    vim.fn.setqflist({}, ' ', {
        title = 'Diagnostic items',
        items = items,
    })

    vim.cmd("copen")
end

vim.keymap.set('n', '<leader>l', ShowLineDiagnosticsInQuickfix,
    { noremap = true, silent = true, desc = "Show line diagnostics in quickfix" })

-----------------------------------------------------------
-- Status line
-----------------------------------------------------------

local function line_diagnostic_summary()
    if vim.fn.mode() == 'i' then
        return ''
    end

    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diags = vim.diagnostic.get(0, { lnum = line })
    if #diags == 0 then
        return ""
    end

    table.sort(diags, function(a, b)
        return a.severity < b.severity
    end)

    local first_diag = diags[1]

    -- Define icons per severity
    local icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = " ",
    }

    local icon = icons[first_diag.severity] or ""
    return icon .. " " .. first_diag.message
end

require('lualine').setup {
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename' },
        lualine_c = {
            {
                line_diagnostic_summary,
                color = function()
                    return { fg = '#ebdbb2' }
                end,
            },
        },
        lualine_x = {
            {
                'diagnostics',
                sources = { 'nvim_diagnostic', 'nvim_lsp' },
            },
            'fileformat',
            'filetype'
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
}

-----------------------------------------------------------
-- Quick fix
-----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        -- Close quickfix window with Esc
        vim.keymap.set("n", "<Esc>", "<cmd>cclose<CR>", { buffer = true, silent = true })
        vim.opt_local.cursorline = true
    end,
})

-- Open quickfix
vim.keymap.set("n", "<leader>q", ":copen<CR>", { noremap = true, silent = true })

-----------------------------------------------------------
-- NeoTree
-----------------------------------------------------------
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle Neo-tree', silent = true })

-----------------------------------------------------------
-- Tmux integration
-----------------------------------------------------------
-- Better-vim-tmux-resizer configurations
-- Disable default mappings
vim.g.tmux_resizer_no_mappings = 1

-- Map Ctrl + Arrow keys
vim.keymap.set('n', '<C-Left>', ':TmuxResizeLeft<CR>', { silent = true })
vim.keymap.set('n', '<C-Down>', ':TmuxResizeDown<CR>', { silent = true })
vim.keymap.set('n', '<C-Up>', ':TmuxResizeUp<CR>', { silent = true })
vim.keymap.set('n', '<C-Right>', ':TmuxResizeRight<CR>', { silent = true })

-- Terminal mode navigation for christoomey/vim-tmux-navigator
map("t", "<C-h>", "<C-\\><C-n>:TmuxNavigateLeft<CR>", { silent = true })
map("t", "<C-j>", "<C-\\><C-n>:TmuxNavigateDown<CR>", { silent = true })
map("t", "<C-k>", "<C-\\><C-n>:TmuxNavigateUp<CR>", { silent = true })
map("t", "<C-l>", "<C-\\><C-n>:TmuxNavigateRight<CR>", { silent = true })

-----------------------------------------------------------
-- Python syntax
-----------------------------------------------------------
vim.g.python_highlight_space_errors = 0
vim.g.python_highlight_func_calls = 0
vim.g.python_highlight_all = 1
