export def "list" []: nothing -> list<string> {
  $env.PATH
    | split row ":"
    | where {$in | path exists}
    | reduce --fold [] {|it, acc| ((ls $it) ++ $acc)}
    | each {$in.name | path split | last}
    | uniq
    | sort
}

export def "find" [name: string]: nothing -> list<string> {
  list | where {$in | str contains $name}
}

export def "dentries" []: nothing -> list<string> {
  $env.XDG_DATA_DIRS 
    | split row ':' 
    | where {|path| $path | path exists} 
    | each {|path| ls $path} | flatten 
    | get name 
    | where {|path| $path | str contains "applications"} 
    | each {|path| ls $path} | flatten
}

export def "dentries find" [name: string]: nothing -> list<string> {
  dentries 
    | where {|app| 
        $app.name 
          | str downcase 
          | str contains ($name | str downcase)
      }
}
