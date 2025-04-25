export def lsmod [] {
  ^lsmod
    | split row '\n'
    | filter {|line| not ($line | str contains "Module")}
    | each {|line|
      $line
        | parse --regex '(?P<Module>\w*)\s*(?P<Size>\d*)\s*(?<UsedByPrograms>\d*)\s*(?<UsedByModules>[\w,]*)?'
        | into record
    }
}

export def "lsmod get" [name: string] {
  lsmod | where Module == $name
}

export def ifconfig_interface [info: string] {
  let int_data = $info | split row ": ";

  let intName = $int_data | get 0;
  let data = $int_data 
    | get 1
    | split row '    ' 
    | each {|row| $row | $row | str trim}
    | filter {|row| $row | is-not-empty}

  {
    interface: $intName
    data: $data
  }
}

export def ifconfig [] {
  ^ifconfig
    | split row "\n\n"
    | each {|info| ifconfig_interface $info}
}

export def "ifconfig get" [interface: string] {
  ifconfig | where interface == $interface
}

export def "fonts weight non-fc" [weight:int] {
  let weight_non_fc_converter = [
    {from: 0, to: 100},
    {from: 40, to: 200},
    {from: 50, to: 300},
    {from: 55, to: 350},
    {from: 75, to: 380},
    {from: 80, to: 400},
    {from: 100, to: 500},
    {from: 180, to: 600},
    {from: 200, to: 700},
    {from: 205, to: 800},
    {from: 210, to: 900},
    {from: 215, to: 1000},
  ];

  let convert = $weight_non_fc_converter | find -c ["from"] $weight

  if ($convert | is-empty) {
    $weight
  } else {
    $convert.to | get 0
  }
  
}

export def "fonts info weight" [
  family: string 
  --path = false, 
  --names = false 
  --styles = false 
  --non-fc-values=false
] {
  let no_filters  = (not $path) and (not $names) and (not $styles);
  let filters = {path: $path, names: $names, styles: $styles}

  (fc-list :family=($family) weight) 
    | split row "\n"
    | each {$in | split row "=" | get 1 | str trim}
    | each {|$weight_str| 
      let weight = if ($weight_str | str starts-with '[') {
        let last = ($weight_str | str length) - 2
        let weights = $weight_str | str substring 1..$last | split row " "

        let weight = $weights | each {$in | into int}

        if $non_fc_values {
          $weight | each {fonts weight non-fc $in}
        } else {
          $weight
        }
      } else { 
        let weight = $weight_str | into int 

        if $non_fc_values {
          fonts weight non-fc $weight
        } else {
          $weight
        }
      };

      let weight_fonts = (fc-list :weight=($weight_str)) 
        | split row "\n" 
        | filter {$in | str contains $family}
        | each {
          let path_names_styles = $in | split row ": "
          let path = $path_names_styles | get 0 
          let names_styles = $path_names_styles | get 1 | split row ":style="
          let names = $names_styles | get 0 | split row ","
          let styles = $names_styles | get 1 | split row ","

          if $no_filters {
            return {path: $path, names: $names, styles: $styles}
          }

          mut res = {}

          if $filters.path {
            $res = $res | insert path {$path} 
          }

          if $filters.names {
            $res = $res | insert names {$names}
          }

          if $filters.styles {
            $res = $res | insert styles {$styles}
          }

          $res
        }
    
      {weight: $weight, fonts: $weight_fonts}
    }
}
