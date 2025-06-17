export def switch-mon-profile [
  profile: string
  --profiles: path
]: nothing -> nothing {
  use std/log

  let path = (match $profiles {
    null => "~/.config/niri/profiles.toml",
    _ => $profiles
  } | path expand);

  if not ($path | path exists) {
    log error $"Profiles file '($path)' doesn't exist!"
    return
  }
  
  let profiles_data = (open $path | transpose name settings) 
  let chosen_profiles = ($profiles_data | where name == $profile)

  if ($chosen_profiles | is-empty) {
    log error $"Profile '($profile)' doesn't exist!"
    log info $"List of available profiles: ($profiles_data | get name)"

    return
  }


  if ($chosen_profiles | length) > 1 {
    log error "Should not be any duplicate-named profiles!";
    return
  }

  let chosen_profile = ($chosen_profiles | into record)
  let chosen_profile_settings = ($chosen_profile.settings | transpose monitor info)

  ($chosen_profile_settings | each {|settings|
    let name = $settings.monitor;

    let scale = $settings.info.scale;
    let mode = $settings.info.mode;
    let position = $settings.info.position

    niri msg output $name scale $scale
    niri msg output $name mode $"($mode.width)x($mode.height)@($mode.refresh)"
    niri msg output $name position set $position.x $position.y
  })
}
