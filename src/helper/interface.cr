module Athena::Console::Helper::Interface
  abstract def helper_set=(helper_set : ACON::Helper::HelperSet? = nil) : Nil
  abstract def helper_set : ACON::Helper::HelperSet
  abstract def name : String
end
