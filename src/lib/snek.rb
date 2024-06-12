require_relative 'logger'
require_relative 'protocol'

module Tron
  Player = Struct.new(:id, :name, :x, :y)

  class Snek
    def initialize(name, passwd, host, port)
      @name = name
      @passwd = passwd

      @host = host
      @port = port

      # networking
      @sock = nil
      @msg_queue = Array.new

      # map and dimensions
      @width = nil
      @height = nil
      @map = nil

      # player info
      @players = Hash.new

      # own info
      @x, @y = nil, nil
      @id = nil
      @dir = 'up'

      # game state
      @joined = false
    end

    def receive
      # receive messages from the server
      @msg_queue += Protocol.receive(@sock)
    end

    def next_msg
      # get the next message from the queue or receive new if empty
      if @msg_queue.empty?
        receive
      end
      @msg_queue.shift
    end

    def normalize(x, y)
      # normalize map coordinates to clip out of bounds values
      [x % @width, y % @height]
    end

    def normx(x)
      # normalize x coordinate
      x % @width
    end

    def normy(y)
      # normalize y coordinate
      y % @height
    end

    def join
      # establish a connection to the server and join the game, then wait for the game to start
      Log.debug("Connecting to #{@host}:#{@port}")
      @sock = Protocol.connect(@host, @port)

      Log.debug("Joining game as #{@name}")
      # join|<name>|<password>
      Protocol.join(@sock, @name, @passwd)

      Log.debug("Waiting for game to start")
      while (last=next_msg).type != 'game'
        # waiting for game to start
        puts last
      end

      # game|<width>|<height>
      @width, @height = last[0].to_i, last[1].to_i
      Log.debug("Game started with dimensions #{@width}x#{@height}")
      @map = Array.new(@width) { Array.new(@height) { nil } }

      @joined = true
    end

    def tick
      # default tick hook
      Log.error("tick method not implemented")
      raise NotImplementedError
    end

    def die(player)
      # default die hook
      Log.info("#{player.name} died")
    end

    def win(wins, losses)
      # default win hook
      Log.info("You win!")
      Log.info("Wins: #{wins}, Losses: #{losses}")
    end

    def lose(wins, losses)
      # default lose hook
      Log.info("You lose!")
      Log.info("Wins: #{wins}, Losses: #{losses}")
    end

    def message(player, message)
      # default message hook
      Log.info("#{player.name}: #{message}")
    end

    def chat(message)
      # send a message to the chat
      # chat|<message>
      Protocol.chat(@sock, message)
    end

    def move(direction)
      # move in a direction
      # move|<direction>
      @dir = direction
      Protocol.move(@sock, direction)
    end

    def handle_msg(msg)
      # handle a message (calls the appropriate hook)
      # only use this if you know what you are doing, useful when writing advanced bots that can't
      # rely on handing over execution flow to the main loop
      case msg.type
      when 'tick'
        # tick
        tick
      when 'lose'
        # lose|<wins>|<losses>
        lose(msg[0].to_i, msg[1].to_i)
        cleanup
      when 'win'
        # win|<wins>|<losses>
        win(msg[0].to_i, msg[1].to_i)
        cleanup
      when 'die'
        # die|<player_id>
        player = @players[msg[0].to_i]
        remove_player(player)
        die(player)
      when 'message'
        # message|<player_id>|<message>
        player = @players[msg[0].to_i]
        message(player, msg[1])
      when 'player'
        # player|<player_id>|<name>
        player = Player.new(msg[0].to_i, msg[1], nil, nil)
        if not player.id == @id then @players[player.id] = player end

        if player.name == @name
          @id = player.id
        end
      when 'pos'
        # pos|<player_id>|<x>|<y>
        if
          msg[0].to_i != @id then player = @players[msg[0].to_i]
        else
          player = Player.new(msg[0].to_i, nil, nil, nil)
        end
        player.x = msg[1].to_i
        player.y = msg[2].to_i
        if player.id == @id then @x, @y = player.x, player.y end

        @map[player.x][player.y] = player.id

      when 'error'
        # error|description
        Log.error("Server returned error: #{msg[0]}")
        Log.warn("Message raw: #{msg.to_s}")
        raise RuntimeError.new(msg[0])
      else
        # type code here
        Log.warn("Unknown message type: #{msg.type}")
        Log.warn("Message raw: #{msg.to_s}")
      end
    end

    def remove_player(player)
      # remove player from map
      @map.each do |row|
        row.map! { |cell| cell == player.id ? nil : cell }
      end
    end

    def run
      # main loop, waits for messages and then handles them appropriately
      while @joined
        msg=next_msg

        handle_msg(msg)
      end
    end

    def cleanup
      # cleanup hook
      Log.info("Cleaning up")
      @sock.close
      @joined = false
    end

  end
end