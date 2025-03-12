{ pkgs, ... }:
{
  imports = [
    ./alpha.nix
    ./fidget.nix
    ./gruvbox.nix
    ./leap.nix
    ./lsp
    ./lualine.nix
    ./neo-tree.nix
    ./neogit.nix
    ./nvim-ts-autotag.nix
    ./nvim-window-picker.nix
    ./oil-nvim.nix
    ./telescope.nix
    ./treesitter.nix
    ./undotree.nix
  ];
  plugins.lazy = {
    enable = true;
    package = pkgs.vimPlugins.lazy-nvim.overrideAttrs (_old: {
      version = "2025-01-20";
      src = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "lazy.nvim";
        rev = "7e6c863bc7563efbdd757a310d17ebc95166cef3";
        sha256 = "sha256-48i6Z6cwccjd5rRRuIyuuFS68J0lAIAEEiSBJ4Vq5vY=";
      };
    });
    # Plugins with no special configuration go here
    plugins = with pkgs.vimPlugins; [
      {
        pkg = gitsigns-nvim;
        config = true;
      }
      {
        pkg = nvim-autopairs;
        config = true;
      }
      {
        pkg = nvim-surround;
        config = true;
      }
      {
        pkg = todo-comments-nvim;
        config = true;
      }
      {
        pkg = vim-tmux-navigator;
      }
      {
        pkg = which-key-nvim;
        config = true;
      }
    ];
  };
}
