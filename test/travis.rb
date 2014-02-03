#!/usr/bin/env ruby
require "fileutils"
require "open3"

# Squish method borrowed from Rails that removes newlines and extra spaces
class String
	def squish
		strip.gsub /\s+/, " "
	end
end

# Compile o-colors normally
result, status = Open3.capture2e "sass main.scss"
raise result unless status.success?
raise "When compiled the module should output some CSS" unless result.length > 0
puts "Checked regular compile"

# Compile o-colors with silent classes
result, status = Open3.capture2e "sass test/silent.scss --style compressed"
raise result unless status.success?
raise "When $o-colors-is-silent is set to true the module should not output any CSS" unless result.length == 0
puts "Checked silent compile"

# Attempting to use an undefined color generates a warning
stdout, stderr, status = Open3.capture3 "sass test/undefined-colors-warn.scss --style compressed"
raise "Using an undefined color should not fail build" unless status.success?
raise "Using an undefined color should throw a warning" unless stderr.squish.match /^WARNING\: Undefined color used on line [0-9]+ of [0-9A-Za-z_\/\\\.]+$/
raise "Using an undefined color should not affect output" unless stdout.squish == ".test{color:#000}"
puts "Checked non-fatal warnings thrown when undefined color used"
