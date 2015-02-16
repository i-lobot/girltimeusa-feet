#!/usr/bin/env ruby
lines = `lynx -dump 'https://twitter.com/search?f=realtime&q=%23girltimeusa%20-from%3Alilbthebasedgod&src=typd' |
  grep -E 'https://twitter.com/[[:alnum:]]+$' |
  sed 's/^.*twitter.com\\///' | sort |  uniq`.split "\n"
lines.each do |line|
  system `ebooks archive #{line}`
end
