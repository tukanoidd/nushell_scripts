export def "init proc-macro-lib" [
  name: string,
] {
  cargo init --lib $name

  cd $name

  (open Cargo.toml
    | upsert lib { proc-macro: true }
    | save -f Cargo.toml)

  cargo add proc-macro2 --features nightly-span-locations

  cargo add syn quote
  cargo add darling --features diagnostics
  cargo add manyhow
}