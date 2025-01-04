{ pkgs, ... }:
{
  plugins.lazy.plugins = with pkgs.vimPlugins; [
    {
      pkg = blink-cmp;
      event = "InsertEnter";
      lazy = false;
      dependencies = [
        friendly-snippets
      ];
      opts = {
        completion = {
          list.selection = "manual";
          documentation.auto_show = true;
        };
        keymap = {
          preset = "none";
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [
            "hide"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<C-l>" = [
            "snippet_forward"
            "fallback"
          ];
          "<C-h>" = [
            "snippet_backward"
            "fallback"
          ];
          "<C-k>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-j>" = [
            "scroll_documentation_down"
            "fallback"
          ];
        };
        appearance = {
          # Sets the fallback highlight groups to nvim-cmp's highlight groups
          # Useful for when your theme doesn't support blink.cmp
          # Will be removed in a future release
          use_nvim_cmp_as_default = true;
          # Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          # Adjusts spacing to ensure icons are aligned
          nerd_font_variant = "mono";
        };
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    }
  ];
}
