#!/usr/bin/env ruby

d = Dir.glob('*/.*').reject{ |n| n =~ %r!/((\.svn)|(\.{1,2}))$! }
d.each do |f|
  file = Dir.pwd + '/' + f
  rmfile = f.split('/')[1]
  puts file
  `rm -f ~/#{rmfile}`
  `ln -s #{file} ~/`
end

puts "-----"

d = Dir.glob('*/*').reject{ |n| n =~ %r!/((\.svn)|(\.{1,2}))$! }
d.each do |f|
  file = Dir.pwd + '/' + f
  puts file
end
