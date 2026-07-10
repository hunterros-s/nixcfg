{
  home =
    { pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        plugins = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
          nvim-lspconfig

          blink-cmp
          friendly-snippets

          telescope-nvim
          plenary-nvim

          nvim-autopairs
        ];

        extraPackages = with pkgs; [
          lua-language-server
          nil
          pyright
          ripgrep
          fd
        ];

        initLua = ''
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

          -- Treesitter highlighting, folds, and indentation.
          -- On NixOS, parsers are provided by:
          --   pkgs.vimPlugins.nvim-treesitter.withAllGrammars
          -- So do NOT use :TSInstall / :TSUpdate here.
          vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
              local ft = vim.bo[args.buf].filetype
              local lang = vim.treesitter.language.get_lang(ft)

              if not lang then
                return
              end

              -- Important: do not use only pcall here.
              -- language.add returns true/nil depending on parser availability.
              local ok = vim.treesitter.language.add(lang)

              if ok then
                vim.treesitter.start(args.buf, lang)

                -- Treesitter folding.
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.wo.foldenable = false

                -- Treesitter indentation. Experimental, but usually fine.
                vim.bo[args.buf].indentexpr =
                  "v:lua.require'nvim-treesitter'.indentexpr()"
              end
            end,
          })

          -- LSP setup, Neovim 0.11+ style.
          -- nvim-lspconfig still provides the server configs;
          -- we just do not use require('lspconfig') anymore.

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

          vim.lsp.enable('lua_ls')
          vim.lsp.enable('nil_ls')
          vim.lsp.enable('pyright')

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
        '';
      };
    };
}
