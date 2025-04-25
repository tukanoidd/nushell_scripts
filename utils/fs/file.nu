export def "from lines" [
  path: path
  lines: list<string>
]: nothing -> nothing {
  $lines | str join "\n" | save -f $path
}
