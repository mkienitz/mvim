{
  description = "A minimal rust development flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixvim, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.devshell.flakeModule
        inputs.pre-commit-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          pkgs,
          config,
          system,
          ...
        }:
        let
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            inherit pkgs;
            module = import ./config; # import the module directly
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            extraSpecialArgs = {
              moovimLib = import ./lib nixvim.lib.nixvim;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          devshells.default = {
            packages = [ pkgs.nil ];
            devshell.startup.pre-commit.text = config.pre-commit.installationScript;
          };

          pre-commit.settings.hooks.treefmt.enable = true;

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              deadnix.enable = true;
              statix.enable = true;
              nixfmt.enable = true;
            };
          };

          checks.default = nixvim.lib.nixvim.check.mkTestDerivationFromNixvimModule nixvimModule;

          packages.default = nvim;
        };
    };
}
