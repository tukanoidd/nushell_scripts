use ../utils input
use ../utils fs file

const TEMPLATE_BASE = "github:yusdacra/nix-cargo-integration"
const TEMPLATE_OPTIONS = {
  crate: {
    template_name: "simple-crate"
  },
  workspace: {
    template_name: "simple-workspace"
  }
};

const FLAKE_PATH = "flake.nix"
const CRATES_FILE = "crates.nix"

const CARGO_TOML_PATH = "Cargo.toml"

const MY_CRATE = "my-crate"

export def rsgen []: nothing -> nothing {
  let template_option_names: list<string> = (
    $TEMPLATE_OPTIONS | transpose name val | get name
  )

  let type: string = (
    input msg list
    "Choose type of project:"
    $template_option_names
  )
  let template_name = ($TEMPLATE_OPTIONS | get $type).template_name
  let template = $"($TEMPLATE_BASE)#($template_name)"

  let path = input msg "Choose path:" -d "./new_project"
  let parsed_path = $path | path parse

  let project_name = input msg "Input project name:" -d $parsed_path.stem
  let bin_name = input msg "Input bin name:" -d $project_name
  let lib_name = match $type {
    "workspace" => (input msg "Input lib name:" -d $"($bin_name)-lib"),
    _ => null
  }
  let channel = input msg list "Choose rust toolchain channel:" ["nightly", "beta", "stable"]
  let edition = input msg list "Choose rust edition:" ["2024", "2021", "2018"]

  mkdir $path
  cd $path

  (
    file from lines
  .envrc [
      "watch_file flake.nix",
      "watch_file crates.nix",
      "",
      "watch_file rust-toolchain.toml",
      "",
      "use flake .",
    ]
  )

  let ignore_lines = ["target/", ".direnv"]

  for path in [.gitignore, .ignore] {
    file from lines $path $ignore_lines
  }

  ({
    toolchain: {
      channel: $channel,
      components: [
        "rustc",
        "rust-src",
        "rust-std",
        "rust-analysis",

        "rustfmt",
        "clippy",
        "rust-analyzer",
      ]
    }
  } | to toml | save -f "rust-toolchain.toml")

  nix flake init -t $template

  if $type == "crate" {
    (open Cargo.toml
      | update package {
          $in
            | upsert name $bin_name
            | upsert edition $edition
      }
      | save -f Cargo.toml)

    ruplacer --go simple $project_name
    ruplacer --go my-crate $bin_name
  } else {
    mv my-workspace-crate $bin_name
    mv my-other-workspace-crate $lib_name

    ruplacer --go my-project $project_name
    ruplacer --go my-workspace-crate $bin_name
    ruplacer --go my-other-workspace-crate $lib_name

    (open Cargo.toml
      | update workspace {
        $in
          | update package {$in | upsert edition $edition}
          | upsert resolver "3"
      }
      | save -f Cargo.toml)
  }
}
