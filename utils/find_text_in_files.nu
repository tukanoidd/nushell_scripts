export def "fdt list" [
  -e:string = "rs" text:string
] {
  let result = (fd -e $e -H -I --exec grep -Hn $text) | split row "\n"

  if ($result | get 0 | is-empty) {
    print "Couldn't find any entries!"
    return;
  }

  let entries = $result | each {|$it|
    let fst_colon = $it | str index-of ":"
    let snd_colon = $it | str index-of --range ($fst_colon + 1).. ":"

    let $path = $it | str substring ..($fst_colon - 1)
    let $line = $it | str substring ($fst_colon + 1)..($snd_colon - 1) | into int
    let $text = $it | str substring ($snd_colon + 1).. 

    {
      path: $path,
      line: $line,
      text: $text
    }
  }

  let unique_paths = $entries | get path | uniq

  let $grouped_entries = $unique_paths | each {|path|
    let path_entries = $entries
      | where {|entry| $entry.path == $path}
      | each {|entry| $entry | select line text}

    { path: $path, lines: $path_entries }
  }

  $grouped_entries
}

export def "fdt find" [-e:string = "rs" text:string path:string] {
  let entries = fdt list -e $e $text
  let path_entries = $entries | where {|entry| $entry.path == $path}
  let entry = match ($path_entries | length) {
    0 => (panic "No etries were found!"),
    1 => ($path_entries | get 0),
    x => (panic "There shouldn't be more than 1 path entry!")
  }
  let lines = $entry.lines

  let file = (open $path --raw | decode utf-8) | split row "\n"

  use std assert

  for line_entry in $entry.lines {
    assert (($file | get ($line_entry.line - 1)) == $line_entry.text)
  }

  $entry
}
