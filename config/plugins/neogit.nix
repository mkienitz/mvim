{
  pkgs,
  moovimLib,
  ...
}:
{
  plugins.lazy.plugins = with pkgs.vimPlugins; [
    {
      pkg = neogit;
      config = true;
      dependencies = [ plenary-nvim ];
      keys = moovimLib.mkLazyKeys [
        {
          lhs = "<leader>gg";
          rhs = "<cmd>Neogit<cr>";
          desc = "Open Neogit";
        }
      ];
    }
  ];
}
