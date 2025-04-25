use ../utils input

use rust.nu rsgen

export def main [] {
  let lang = input msg list "Choose language" ["rust"]

  match $lang {
    "rust" => rsgen,
    _ => (print $"($lang) is not supported!")
  }
}

