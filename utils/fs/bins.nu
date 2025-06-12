export def "list" []: nothing -> list<string> {
  $env.PATH
    | split row ":"
    | filter {$in | path exists}
    | reduce --fold [] {|it, acc| ((ls $it) ++ $acc)}
    | each {$in.name | path split | last}
    | uniq
    | sort
}

export def "find" [name: string]: nothing -> list<string> {
  list | filter {$in | str contains $name}
}

export def "dentries" []: nothing -> list<string> {
  $env.XDG_DATA_DIRS 
    | split row ':' 
    | filter {|path| $path | path exists} 
    | each {|path| ls $path} | flatten 
    | get name 
    | filter {|path| $path | str contains "applications"} 
    | each {|path| ls $path} | flatten
}

export def "dentries find" [name: string]: nothing -> list<string> {
  dentries 
    | filter {|app| 
        $app.name 
          | str downcase 
          | str contains ($name | str downcase)
      }
}
