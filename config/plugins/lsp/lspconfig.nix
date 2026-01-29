{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.nixvim) toRawKeys;
  inherit (builtins) map listToAttrs;
  vpkgs = pkgs.vimPlugins;
  on_attach =
    # lua
    ''
      function(client, bufnr)
        local wk = require("which-key")
        wk.add({
          { "K", vim.lsp.buf.hover, desc = "Hover documentation", buffer = bufnr },
          { "gd", vim.lsp.buf.definition, desc = "Definition", buffer = bufnr },
          { "gD", vim.lsp.buf.declaration, desc = "Declaration", buffer = bufnr },
          { "gi", vim.lsp.buf.implementation, desc = "Implementation", buffer = bufnr },
          { "go", vim.lsp.buf.type_definition, desc = "Type definition", buffer = bufnr },
          { "gr", vim.lsp.buf.references, desc = "References", buffer = bufnr },
          { "[d", vim.diagnostic.goto_next, desc ="Jump to next diagnostic", buffer = bufnr },
          { "]d", vim.diagnostic.goto_prev, desc ="Jump to previous diagnostic", buffer = bufnr },
          { "<leader>c", vim.lsp.buf.code_action, desc = "Show code actions", buffer = bufnr },
          { "<leader>rn", vim.lsp.buf.rename, desc = "Rename symbol", buffer = bufnr },
          { "<leader>vws", vim.lsp.buf.workspace_symbol, desc = "Find symbol in workspace", buffer = bufnr },
          { "<leader>e", vim.diagnostic.open_float, desc = "Show diagnostics for line", buffer = bufnr },
          { "<leader>E", require("telescope.builtin").diagnostics, desc = "Show diagnostics for buffer", buffer = bufnr },
          { "<leader>F", vim.lsp.buf.format, desc = "Format buffer", buffer = bufnr },
        })
      end
    '';
in
{
  plugins.lazy.plugins = [
    {
      pkg = vpkgs.crates-nvim;
      dependencies = with vpkgs; [
        plenary-nvim
      ];
      opts = {
        lsp = {
          enabled = true;
          actions = true;
          completion = true;
          hover = true;
          on_attach.__raw = on_attach;
        };
      };
    }
    {
      pkg = vpkgs.nvim-lspconfig;
      dependencies = with vpkgs; [
        dressing-nvim
        which-key-nvim
        blink-cmp
        lean-nvim
        telescope-nvim
        crates-nvim
      ];
    }
  ];
  lsp = {
    servers =
      # NOTE: list of generic servers we want to enable and just use
      # the default configs provided by nvim-lspconfig
      listToAttrs (
        map
          (server_name: {
            name = server_name;
            value = {
              enable = true;
              package = null;
            };
          })
          [
            "gleam"
            "gopls"
            "hls"
            "omnisharp"
            "leanls"
            "pyright"
            "svelte"
            "tailwindcss"
            "templ"
            "ts_ls"
          ]
      )
      // {
        # BUG: This appears overriden by the default on_attach functions of the following LSPs
        # Therefore we add it manually for each entry
        "*".config.on_attach.__raw = on_attach;
        lua_ls = {
          enable = true;
          package = null;
          config = {
            on_attach.__raw = on_attach;
            Lua = {
              diagnostics.globals = [ "vim" ];
              # NOTE: use toRawKeys so the lua expressions end up in the table
              workspace.library = toRawKeys {
                "vim.fn.expand(\"$VIMRUNTIME/lua\")" = true;
                "vim.fn.stdpath(\"config\") .. \"/lua\"" = true;
              };
            };
          };
        };
        tinymist = {
          enable = true;
          package = null;
          config.on_attach.__raw = on_attach;
        };
        ty = {
          enable = true;
          package = null;
          config.on_attach.__raw = on_attach;
        };
        nil_ls = {
          enable = true;
          package = null;
          config = {
            on_attach.__raw = on_attach;
            nil.formatting.command = [
              "${(lib.getExe pkgs.nixfmt)}"
              "--quiet"
            ];
          };
        };
        rust_analyzer = {
          enable = true;
          package = null;
          config = {
            on_attach.__raw = on_attach;
            rust-analyzer = {
              checkOnSave.command = "clippy";
              files.excludeDirs = [ ".direnv" ];
              cargo.features = [ "ssr " ];
              procMacro.ignored.leptos_macro = [
                "server"
              ];
            };
          };
        };
      };
  };
}
