# module that implements the for the GPN-TRON-Protocol

require 'socket'

module Protocol
  class Message
    def initialize(type, *data)
      @type = type
      @data = data
    end
    def to_s
      "#{@type}|#{@data.join('|')}"
    end
    def self.from_s(str)
      Message.new(*str.split('|'))
    end

    def [](idx)
      @data[idx]
    end

    def []=(idx, val)
      @data[idx] = val
    end

    attr_accessor :type, :data
  end

  def self.connect(host, port)
    TCPSocket.new(host, port)
  end

  def self.join(sock, name, password)
    send(sock, Message.new('join', name, password))
  end

  def self.move(sock, direction)
    send(sock, Message.new('move', direction))
  end

  def self.chat(sock, message)
    send(sock, Message.new('chat', message))
  end

  def self.receive_raw(sock)
    sock.gets
  end

  def self.send_raw(sock, msg)
    sock.puts(msg)
  end

  def self.receive(sock)
    msgs = receive_raw(sock).split("\n")
    msgs.map { |msg| Message.from_s(msg)}
  end

  def self.send(sock, msg)
    send_raw(sock, msg.to_s)
  end
end
