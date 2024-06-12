require "pastel"

module Log
  def self.debug(msg)
    puts Pastel.new.magenta.bold(msg)
  end
  def self.info(msg)
    puts Pastel.new.blue.bold(msg)
  end

  def self.error(msg)
    puts Pastel.new.red.bold(msg)
  end

  def self.warn(msg)
    puts Pastel.new.yellow.bold(msg)
  end
end