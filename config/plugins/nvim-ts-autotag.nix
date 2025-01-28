{
  pkgs,
  ...
}:
{
  plugins.lazy.plugins = with pkgs.vimPlugins; [
    {
      pkg = nvim-ts-autotag;
      # opts = {
      #   enable_rename = true;
      #   enable_close = true;
      #   enable_close_on_clash = true;
      #   filetypes = [
      #     "svelte"
      #     "html"
      #   ];
      # };
      lazy = false;
      config =
        # lua
        ''
          function(_, opts)
            require("nvim-ts-autotag").setup({
              opts = {
                enable_rename = true,
                enable_close = true,
                enable_close_on_clash = true,
                filetypes = { "svelte", "html" },
              },
            })
          end
        '';
    }
  ];
}
