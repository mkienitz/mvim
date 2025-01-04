nixvimLib: rec {
  mkLazyKey =
    {
      lhs,
      rhs,
      desc,
    }:
    (
      (nixvimLib.listToUnkeyedAttrs [
        lhs
        rhs
      ])
      // {
        inherit desc;
      }
    );

  mkLazyKeys = bindings: {
    __raw = nixvimLib.toLuaObject (builtins.map mkLazyKey bindings);
  };
}
