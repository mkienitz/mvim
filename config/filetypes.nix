{ config, ... }:
{
  files =
    let
      mkIndentSettings = lang: width: expandTab: {
        name = "ftplugin/${lang}.lua";
        value = {
          localOpts = {
            expandtab = expandTab;
            shiftwidth = width;
            tabstop = width;
            softtabstop = width;
          };
        };
      };
    in
    builtins.listToAttrs [
      (mkIndentSettings "haskell" 2 true)
      (mkIndentSettings "html" 2 false)
      (mkIndentSettings "javascript" 2 false)
      (mkIndentSettings "lua" 2 false)
      (mkIndentSettings "nix" 2 true)
      (mkIndentSettings "svelte" 2 false)
      (mkIndentSettings "typescript" 2 false)
      (mkIndentSettings "typescriptreact" 2 false)
      (mkIndentSettings "typst" 2 true)
      (mkIndentSettings "gleam" 2 true)
    ];
  extraConfigLua =
    # lua
    ''
      vim.filetype.add({
        extension = {
          typ = "typst",
          typst = "typst",
        }
      })
      -- NOTE: nixvim standalone does not add extraFiles to runtimepath
      -- https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=files#impurertp
      vim.opt.runtimepath:prepend("${config.build.extraFiles}")
    '';
}
