local lsp_installer = require('nvim-lsp-installer')
local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(_, bufnr)
  	-- Enable completion triggered by <c-x><c-o>
  	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  	-- Mappings.
  	-- See `:help vim.lsp.*` for documentation on any of the below functions
  	local bufopts = { noremap=true, silent=true, buffer=bufnr }
  	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  	vim.keymap.set('n', '<space>wl', function()
  	  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  	end, bufopts)
  	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  	vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local lsp_flags = {
	debounce_text_changes = 150, -- default
}

require("nvim-lsp-installer").setup {
    ensure_installed = { 'sumneko_lua' },
    automatic_installation = false,

    ui = {
        check_outdated_servers_on_open = true,
        border = "none",
        icons = {
            server_installed = "◍",
            server_pending = "◍",
            server_uninstalled = "◍",
        },
        keymaps = {
            toggle_server_expand = "<CR>",
            install_server = "i",
            update_server = "u",
            check_server_version = "c",
            update_all_servers = "U",
            check_outdated_servers = "C",
            uninstall_server = "X",
        },
    },
    pip = {
        install_args = {},
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 4,
    github = {
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
    },
}

local ls_path_prefix = 'user.language-servers.language-'
local function ls_prefix(name)
    return string.format('%s%s', ls_path_prefix, name)
end

for _, lsp in ipairs(lsp_installer.get_installed_servers()) do
    local settings

    if lsp.name == 'sumneko_lua' then
        settings = require(ls_prefix('lua'))
    elseif lsp.name == 'gopls' then
        settings = require(ls_prefix('go'))
    end

    nvim_lsp[lsp.name].setup {
        on_attach = on_attach,
        flags = lsp_flags,
        settings = settings,
        capabilities = capabilities,
    }
end

-- Other Settings

-- Diagnostic Config
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
})

-- Icons for Native LSP
local icons = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = ""
}

local kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(kinds) do
    kinds[i] = icons[kind] or kind
end

-- Diagnostic Symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
