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
      rust-analyzer
      zls
      ripgrep
      fd
    ];

    initLua = builtins.readFile ./neovim.lua;
  };
}
