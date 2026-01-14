{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    tree-sitter
    nodejs
    gcc
  ];
  plugins.lazy.plugins =
    with pkgs.vimPlugins;
    [
      {
        pkg = nvim-treesitter-textobjects.overrideAttrs (_old: {
          src = pkgs.fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "nvim-treesitter-textobjects";
            rev = "d0d12338230c1ce4ce27373f5b8d50a8c691794b";
            sha256 = "sha256-Ma0brcx75JOUuCM7prc69cLpCitCfS8E4X3E96rZ0j8=";
          };
        });
        dependencies = [ nvim-treesitter ];
        enabled = false;
        event = [
          "BufReadPost"
          "BufNewFile"
        ];
        opts = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = false;
          };
          indent = {
            enable = true;
          };
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-space>";
              node_incremental = "<C-space>";
              scope_incremental = "<C-S-space>";
              node_decremental = "<bs>";
            };
          };
          textobjects = {
            select = {
              enable = true;
              keymaps = {
                "a=" = {
                  query = "@assignment.outer";
                  desc = "Select outer part of an assignment";
                };
                "i=" = {
                  query = "@assignment.inner";
                  desc = "Select inner part of an assignment";
                };
                "l=" = {
                  query = "@assignment.lhs";
                  desc = "Select left side of an assignment";
                };
                "r=" = {
                  query = "@assignment.rhs";
                  desc = "Select right side of an assignment";
                };
                "aa" = {
                  query = "@parameter.outer";
                  desc = "Select outer part of a parameter/field";
                };
                "ia" = {
                  query = "@parameter.inner";
                  desc = "Select inner part of a parameter/field";
                };
                "ai" = {
                  query = "@conditional.outer";
                  desc = "Select outer part of a conditional";
                };
                "ii" = {
                  query = "@conditional.inner";
                  desc = "Select inner part of a conditional";
                };
                "al" = {
                  query = "@loop.outer";
                  desc = "Select outer part of a loop";
                };
                "il" = {
                  query = "@loop.inner";
                  desc = "Select inner part of a loop";
                };
                "ab" = {
                  query = "@block.outer";
                  desc = "Select outer part of a block";
                };
                "ib" = {
                  query = "@block.inner";
                  desc = "Select inner part of a block";
                };
                "af" = {
                  query = "@call.outer";
                  desc = "Select outer part of a function call";
                };
                "if" = {
                  query = "@call.inner";
                  desc = "Select inner part of a function call";
                };
                "ac" = {
                  query = "@class.outer";
                  desc = "Select outer part of a class";
                };
                "ic" = {
                  query = "@class.inner";
                  desc = "Select inner part of a class";
                };
              };
              lookahead = true;
              include_surrounding_whitespace = true;
            };
            move = {
              enable = true;
              set_jumps = true;
              goto_next_start = {
                "]m" = {
                  query = "@function.outer";
                  desc = "Next function start";
                };
                "]]" = {
                  query = "@class.outer";
                  desc = "Next class start";
                };
              };
              goto_next_end = {
                "]M" = {
                  query = "@function.outer";
                  desc = "Next function end";
                };
                "][" = {
                  query = "@class.outer";
                  desc = "Next class ends";
                };
              };
              goto_previous_start = {
                "[m" = {
                  query = "@function.outer";
                  desc = "Previous function start";
                };
                "[[" = {
                  query = "@class.outer";
                  desc = "Previous class start";
                };
              };
              goto_previous_end = {
                "[M" = {
                  query = "@function.outer";
                  desc = "Previous function end";
                };
                "[]" = {
                  query = "@class.outer";
                  desc = "Previous class end";
                };
              };
            };
            swap = {
              enable = true;
              swap_next = {
                "<leader>a" = {
                  query = "@parameter.inner";
                  desc = "Swap parameter with next";
                };
              };
              swap_previous = {
                "<leader>A" = {
                  query = "@parameter.inner";
                  desc = "Swap parameter with next";
                };
              };
            };
          };
        };
        config = # lua
          ''
            function(_, opts)
                require("nvim-treesitter-textobjects").setup(opts)
            end
          '';
      }
      {
        pkg = nvim-treesitter;
        opts =
          let
            parsersDir = "${pkgs.symlinkJoin {
              name = "treesitter-parsers";
              paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
            }}";
          in
          {
            install_dir = parsersDir;
          };
        config = # lua
          ''
            function(_, opts)
                require("nvim-treesitter").setup(opts)
            end
          '';
      }
    ]
    # TODO: Remove hack until query dependency handling is fixed upstream:
    # https://github.com/nixos/nixpkgs/issues/478561
    # https://github.com/NixOS/nixpkgs/pull/478853
    # https://github.com/NotAShelf/nvf/pull/1315
    ++ (map
      (pkg: {
        inherit pkg;
        enabled = true;
      })
      (
        let
          qs = pkgs.vimPlugins.nvim-treesitter.queries;
        in
        [
          qs.ecma
          qs.html_tags
          qs.jsx
        ]
      )
    );
  autoCmd = [
    {
      event = "FileType";
      pattern = builtins.attrNames pkgs.vimPlugins.nvim-treesitter.parsers;
      callback = {
        __raw = # lua
          ''
            function()
              vim.treesitter.start()
            end
          '';
      };
    }
  ];
}
