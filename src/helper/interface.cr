module Athena::Console::Helper::Interface
  abstract def helper_set=(helper_set : ACON::Helper::HelperSet?)
  abstract def helper_set : ACON::Helper::HelperSet?
end
