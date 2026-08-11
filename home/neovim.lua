vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250
vim.opt.wrap = false

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if not lang then
      return
    end

    local ok = vim.treesitter.language.add(lang)

    if ok then
      vim.treesitter.start(args.buf, lang)

      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldenable = false

      vim.bo[args.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

vim.lsp.config('nil_ls', {})
vim.lsp.config('pyright', {})
vim.lsp.config('rust_analyzer', {})
vim.lsp.config('zls', {})

vim.lsp.enable('lua_ls')
vim.lsp.enable('nil_ls')
vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('zls')

-- Telescope basics.
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- Completion
require('blink.cmp').setup({
  keymap = {
    preset = 'super-tab', -- 'enter' or 'super-tab'
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
    },

    ghost_text = {
      enabled = true,
    },
  },

  signature = {
    enabled = true,
  },

  -- potentially safer on nix. look into this more
  fuzzy = {
    implementation = 'lua',
  },
})

-- (), {}, [], quotes, etc.
require('nvim-autopairs').setup({})
