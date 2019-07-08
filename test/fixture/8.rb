class Needle
  def self.poke
  end
end

Hay = Struct.new(:lol)

class Haystack
  def hide
    puts "i am a haystack"
    @contents = [
      Hay.new,
      Needle.poke,
      Hay.new,
    ]
  end

  module Deep
    def find
      @contents.find { |c| c.is_a?(Needle) }
    end
  end
end
