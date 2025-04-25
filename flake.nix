{
  description = "A collection of nushell scripts";

  inputs = {
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
    nutest,
    git_nu,
    nupm,
    ...
  }: {
    utils = ./utils;
    nunps = ./nunps;

    nutest = nutest;
    git_nu = git_nu;
    nupm = nupm;
  };
}
