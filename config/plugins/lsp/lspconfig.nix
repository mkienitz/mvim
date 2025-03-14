{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.nixvim) emptyTable toRawKeys;
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
        nvim-cmp
      ];
      opts = {
        lsp = {
          enabled = true;
          actions = true;
          completion = true;
          hover = true;
          on_attach.__raw = on_attach;
        };
        completion.cmp.enabled = true;
      };
    }
    {
      pkg = vpkgs.nvim-lspconfig;
      event = [
        "BufReadPre"
        "BufNewFile"
      ];
      dependencies = with vpkgs; [
        dressing-nvim
        which-key-nvim
        blink-cmp
        lean-nvim
        telescope-nvim
        crates-nvim
      ];
      opts = {
        servers =
          # Generic servers
          listToAttrs (
            map
              (server_name: {
                name = server_name;
                value = emptyTable;
              })
              [
                "gleam"
                "gopls"
                "hls"
                "leanls"
                "pyright"
                "svelte"
                "tailwindcss"
                "tinymist"
                "ts_ls"
              ]
          )
          // {

            lua_ls.settings.Lua = {
              diagnostics.globals = [ "vim" ];
              workspace.library = toRawKeys {
                "vim.fn.expand(\"$VIMRUNTIME/lua\")" = true;
                "vim.fn.stdpath(\"config\") .. \"/lua\"" = true;
              };
            };

            nil_ls.settings.nil.formatting.command = [
              "${(lib.getExe pkgs.nixfmt-rfc-style)}"
              "--quiet"
            ];

            rust_analyzer.settings.rust-analyzer = {
              checkOnSave.command = "clippy";
              files.excludeDirs = [ ".direnv" ];
              cargo.features = [ "ssr " ];
              procMacro.ignored.leptos_macro = [
                "server"
              ];
            };
          };
      };
      config =
        # lua
        ''
          function(_, opts)
            local lspconfig = require("lspconfig")
            for server_name, server_opts in pairs(opts.servers) do
              server_opts.capabilities = require("blink.cmp").get_lsp_capabilities(server_opts.capabilities)
              server_opts.on_attach = ${on_attach}
              lspconfig[server_name].setup(server_opts)
            end
            require("lean").setup({
              lsp = { on_attach = ${on_attach}}
            })
          end
        '';
    }
  ];
}
