{
  description = "A collection of nushell scripts";

  inputs = {
    nix-lib.url = "github:ekala-project/nix-lib";

    nu_scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    nutest = {
      url = "github:vyadh/nutest";
      flake = false;
    };
    git_nu = {
      url = "github:fj0r/git.nu";
      flake = false;
    };
    nupm = {
      url = "github:nushell/nupm";
      flake = false;
    };
  };

  outputs = {
    nix-lib,
    nu_scripts,
    nutest,
    git_nu,
    nupm,
    ...
  }: let
    lib = nix-lib.lib;
  in {
    theme = selected: let
      file = builtins.toPath "${nu_scripts}/themes/nu-themes/${selected}.nu";
    in {
      use = "use ${file}";
      set = "$env.config.color_config = (${selected})";
    };

    modules = {
      utils = ./utils;
      nunps = ./nunps;
    };

    external = {
      modules = let
        mod_dir = builtins.toPath "${nu_scripts}/modules/";
        mod_dir_entries = builtins.readDir mod_dir;
        mod_dir_dirs = lib.filterAttrs (_name: ty: ty == "directory") mod_dir_entries;
        mod_dir_dir_names = builtins.map ({
          name,
          value,
        }:
          name) (lib.attrsToList mod_dir_dirs);
      in
        builtins.listToAttrs (builtins.map (name: {
            inherit name;
            value = builtins.toPath "${mod_dir}/${name}";
          })
          mod_dir_dir_names);

      scripts = {
        nutest = nutest;
        git_nu = git_nu;
        nupm = nupm;

        sourced = builtins.toPath "${nu_scripts}/sourced/";
        hooks = builtins.toPath "${nu_scripts}/nu-hooks/nu-hooks";
      };
    };
  };
}
