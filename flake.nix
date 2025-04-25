{
  description = "A collection of nushell scripts";

  outputs = {...}: {
    utils = ./utils;
    nunps = ./nunps;
  };
}
