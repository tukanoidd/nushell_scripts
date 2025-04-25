export def "gen envrc" [--impure] {
  let impure_str = if $impure {" --impure"} else {""};
  $"use flake .($impure_str)" | save -f .envrc
  direnv allow
}

export def "flake update interactive" [flake_path:path = "./flake.nix"] {
  let flake = (open $flake_path)
  let flake_dir = ($flake_path | path dirname)

  let inputs_start = ($flake | str index-of "inputs")
  let outputs_start = ($flake | str index-of "outputs")

  let inputs = ($flake | str substring $inputs_start..($outputs_start - 1) | lines | each {|l| $l | str trim})  

  let lock_path = ($flake_path | path dirname | path join "flake.lock")
  let lock = (open $lock_path | from json)
  let nodes = ($lock.nodes | transpose name val | filter {|v| $inputs | any {|il| $il | str starts-with $v.name}} | each {$in.name})

  let selected_inputs = ($nodes | input list -m)

  cd $flake_dir

  nix flake update ...$selected_inputs
} 

export def "flake init devenv" [] {
  nix flake init -t github:cachix/devenv/#flake-parts
  gen envrc --impure
}

export def "flake init crate" [] {
  nix flake init -t github:yusdacra/nix-cargo-integration
  gen envrc
}

export def "collect-all-garbage" [] {
  sudo nix-collect-garbage -d
  sudo nix-collect-garbage
  nix-collect-garbage -d
  nix-collect-garbage
}

export def tsearch [] {
  tv nixpkgs
}

export def "tsearch index" [] {
  nix-search-tv index --flake nixpkgs
}
