{
  pkgs,
  moovimLib,
  ...
}:
{
  plugins.lazy.plugins = with pkgs.vimPlugins; [
    {
      pkg = leap-nvim;
      lazy = false;
      opts = {
        case_sensitive = true;
      };
      keys = moovimLib.mkLazyKeys [
        {
          lhs = "s";
          rhs = "<Plug>(leap-forward-to)";
          desc = "Leap forward";
        }
        {
          lhs = "S";
          rhs = "<Plug>(leap-backward-to)";
          desc = "Leap backward";
        }
        {
          lhs = "gs";
          rhs = "<Plug>(leap-cross-windows)";
          desc = "Leap across windows";
        }
      ];
    }
  ];
}
