require_relative 'bot.rb'

while true
  s = Snail.new('snail', "passwd", 'localhost', 4000)
  puts 'bot instantiated, joining ... '
  s.join
  puts 'joined, starting loop ... '
  s.run
  puts 'end'
end
