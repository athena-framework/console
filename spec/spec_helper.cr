require "spec"

require "athena-spec"
require "../src/athena-console"
require "../src/spec"

require "./fixtures/commands/io_command"
require "./fixtures/**"

ASPEC.run_all
