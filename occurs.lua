#!/usr/bin/env lua
prog = {
  name = "occurs",
  banner = "occurs 0.85 (27 Sep 2011) by Reuben Thomas <rrt@sc3d.org>",
  purpose = "Count the occurrences of each symbol in a file.",
  notes = "The default symbol type is words (-s \"([[:alpha:]]+)\"); other useful settings\n" ..
    "include:\n\n" ..
    "  non-white-space characters: -s \"[^[:space:]]+\"\n" ..
    "  alphanumerics and underscores: -s \"[[:alnum:]_]+\"\n" ..
    "  XML tags: -s \"<([a-zA-Z_:][a-zA-Z_:.0-9-]*)[[:space:]>]\""
}

-- FIXME: rewrite in Python

require "std"
require "rex_posix"

-- Process a file
local pattern -- regexp, defined below
function occurs (file, number)
  local symbol, freq = {}, {}
  for line in io.lines () do
    rex_posix.gsub (line, pattern,
                    function (s)
                      if not freq[s] then
                        table.insert (symbol, s)
                        freq[s] = 1
                      else
                        freq[s] = freq[s] + 1
                      end
                  end)
  end
  if not getopt.opt.nocount then
    io.stderr:write (file .. ": " .. tostring (#symbol) .. " symbols\n")
  end
  for s in list.elems (symbol) do
    io.write (s)
    if not getopt.opt.nocount then
      io.write (" " .. tostring (freq[s]))
    end
    io.write ("\n")
  end
  if number < #arg then
    io.write ("\n")
  end
end

-- Command-line options
options = {
  Option {{"nocount", "n"}, "don't show the frequencies or total"},
  Option {{"symbol", "s"}, "symbols are given by REGEXP", "Req", "REGEXP"},
}


-- Parse command-line args
os.setlocale ("")
getopt.processArgs ()
local symbolPat = getopt.opt.symbol or "([[:alpha:]]+)"

-- Compile symbol-matching regexp
local ok
ok, pattern = pcall (rex_posix.new, symbolPat)
if not ok then
  io.stderr:write (prog.name .. ": " .. pattern .. "\n")
  os.exit (1)
end

io.processFiles (occurs)
