#!/usr/bin/env ruby

require "fileutils"
require "open3"
require "securerandom"
require "tmpdir"

template = <<~TEMPLATE
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <title>Console</title>
      <link rel=stylesheet href="./console.css">
      <script src="https://unpkg.com/html2canvas@1.0.0-rc.1/dist/html2canvas.min.js"></script>
      <script src="./console.js"></script>
    </head>
    <body>
      <pre></pre>
      <button>Convert to PNG</button>
    </body>
  </html>
TEMPLATE

ascii = if ARGV.empty?
          $stdin.read
        else
          out = Open3.popen3({ "CLICOLOR_FORCE" => "1" }, *ARGV) do |_in, stdout, _err, _thr|
            stdout.read
          end
          out.prepend ["$", *ARGV, "\n"].join(" ")
        end

ascii.rstrip!
ascii.gsub!("&", "&amp;")
ascii.gsub!("<", "&lt;")
ascii.gsub!(">", "&gt;")
ascii.gsub!("\e[0;31;49m", "<span class=red>")
ascii.gsub!("\e[0;32;49m", "<span class=green>")
ascii.gsub!("\e[0;33;49m", "<span class=yellow>")
ascii.gsub!("\e[0;34;49m", "<span class=blue>")
ascii.gsub!("\e[0;90;49m", "<span class=gray>")
ascii.gsub!("\e[0m", "</span>")
html = template.sub("<pre>", "<pre>#{ascii}")

out = File.join(Dir.tmpdir, "console-#{SecureRandom.hex(8)}.html")
IO.write(out, html)
%w[console.css console.js].each do |file|
  FileUtils.cp(File.expand_path(file, __dir__), Dir.tmpdir)
end
system "open", out
