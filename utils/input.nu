export def msg [msg: string, -d: string]: nothing -> string {
  let default_msg: string = match $d {
    null => "",
    _ => $" \(($d))"
  };
  print $"($msg)($default_msg)"

  if $d == null {
    input
  } else {
    input -d $d
  }
}

export def "msg list" [msg: string, list: list<string>]: nothing -> string {
  print $msg
  $list | input list
}
