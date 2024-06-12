# GPN-Tron Library
This is a ruby library for the GPN-Tron game. 
There is also an implementation in Python, which can be found [here](https://github.com/lstuma/gpn-tron-client). 

# Usage
To use this library, just include the lib folder in your project and require the `lib/snek.rb` file. 
Then you can create a new game and start it. 

```ruby
require_relative 'lib/snek'

class Bot < Tron::Snek
    def tick
        # Your code here
        move('up')
    end
end

bot = Bot.new('testbot', 'password', 'localhost', 4000)
bot.join
bot.run
```

The above code is the minimal implementation of a bot. You **HAVE** to implement the `tick` method. There are a couple more methods that will be called at certain events. These are:
- `die(player)`: Called when a player dies
- `win`: Called when the bot wins
- `lose`: Called when the bot loses
- `tick`: Called every tick, should be used to move the bot
- `message(player, message)`: Called when a message is received

Furthermore there are some methods that can be called by the bot to interact with the game:
- `move(direction)`: Move in a certain direction, only call this once per tick
- `chat(message)`: Send a message to the chat

And there are a few methods that are very useful when writing a bot:
- `normalize(x, y)`: Normalize the coordinates (wrap around the map)
- `normx(x)`: Normalize the x coordinate
- `normy(y)`: Normalize the y coordinate

Furthermore there is an arsenal of attributes that can be used to get information about the game state:
- `@width`: The width of the map
- `@height`: The height of the map
- `@map`: The map, value is either `nil` (empty) or the id of the player that is at that position
- `@players`: Hashmap of other players (bot not included) with their id as key. The players are represented as a Struct with the following attributes:
  - `@id`: The id of the player
  - `@name`: The name of the player
  - `@x` and `@y`: The coordinates of the player
- `@x` and `@y`: The coordinates of the bot
- `@id`: The id of the bot
- `@dir`: The last direction the bot moved in

Now that we've learned about the methods and attributes, let's write a simple bot that doesn't crash into other players:

```ruby
require_relative 'lib/snek'

class Bot < Tron::Snek
  def tick
    if @map[@x][normy(@y-1)].nil?
      move('up')
    elsif @map[normx(@x+1)][@y].nil?
      move('right')
    elsif @map[@x][normy(@y+1)].nil?
      move('down')
    elsif @map[normx(@x-1)][@y].nil?
      move('left')
    else
      self.chat('Goodbye World!')
      move('up')
    end
  end
end

bot = Bot.new('testbot', 'password', '127.0.0.1', 4000)
bot.join
bot.run
```
If you want to have a look at slightly more advanced bots, you can have a look at the bot implementations in the `bot.rb` file.


# Testing
If you want to test your bot, you can run the game locally. You can find the game [here](https://github.com/freehuntx/gpn-tron).

# License
This project is licensed under the CC Zero License - see the [LICENSE](LICENSE) file for details.