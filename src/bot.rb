require_relative 'lib/snek'
require_relative 'lib/logger'

class Snail < Tron::Snek
  def tick
    Log.debug("Opportunities: #{opportunities}")

    # move to the direction with the most opportunity
    direction = opportunities.max_by{|k,v| v}[0]
    Log.info("Moving #{direction}")
    move(direction)
  end

  def opportunities
    # returns a hash of directions and their opportunity factor
    # the opportunity factor is calculated by the opportunity method
    opportunities = {
      'up' => opportunity(@x, @y-1, 'up',0, -1),
      'down' => opportunity(@x, @y+1, 'down', 0, 1),
      'left' => opportunity(@x-1, @y, 'left', -1, 0),
      'right' => opportunity(@x+1, @y, 'right', 1, 0),
    }
  end

  def opportunity(x, y, dir, dirx, diry)
    # returns the opportunity factor of a cell
    # essentially, the opportunity factor is made up of a few
    # variables but the most important one is the area that can be
    # reached from the cell

    x,y = normalize(x,y)

    unless @map[x][y].nil?
      # cell is occupied
      return 0
    end

    # opportunity factor is made up of a few more variables than just the area, thus the modifier
    modifier = 1.0

    @map[x][y] = @id
    # calculate area that can be reached from the cell
    areas = [
      calc_area(x+1, y, 10),
      calc_area(x-1, y, 10),
      calc_area(x, y+1, 10),
      calc_area(x, y-1, 10),
    ]
    # return map to original state
    @map[x][y] = nil

    unless @map[normx(x+dirx)][normy(y+diry)].nil?
      # if there is a cell is in the direction of the current movement (closing gap), increase the modifier
      modifier *= 1
    end
    if (player=player_near(x, y))
      # if a player is near the cell, decrease the modifier
      log.info("Player near: #{player.name}")
      modifier *= 0.1
    end
    if @dir == dir
      modifier *= 1.2
    end


    max_area = areas.max * modifier

  end

  def player_near(x, y)
    # returns true if a player is near the cell
    offsets = [[1,0], [-1,0], [0,1], [0,-1]]
    pos = offsets.each{|offx, offy| [x+offx, y+offy]}

    @players.values do |player|
      if pos.include?([player.x, player.y])
        return player
      end
    end

    false
  end

  def calc_area(x, y, depth, repetition_map=nil)
    # calculates the area that can be reached from a cell, given a certain max recursion depth
    if depth == 0 then return 0 end

    if repetition_map.nil?
      # initialize repition map
      # used to keep track of visited cells
      repetition_map = Array.new(@width) { Array.new(@height) { nil }}
    end

    x,y = normalize(x,y)

    if repetition_map[x][y].nil? and @map[x][y].nil?
      # mark cell as visited
      repetition_map[x][y] = true
      # calculate area
      1 +
        calc_area(x+1, y, depth-1, repetition_map) +
        calc_area(x-1, y, depth-1, repetition_map) +
        calc_area(x, y+1, depth-1, repetition_map) +
        calc_area(x, y-1, depth-1, repetition_map)
    else
      0
    end


  end
end
