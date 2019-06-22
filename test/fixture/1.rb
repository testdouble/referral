# Definitions:
module Bar
  STUFFS = []
  def self.baz
  end

  def qux!
  end

  class Foo
    THINGS = "HI"

    def self.foz
    end

    def fiz
    end
  end
end

# References:
Bar.baz

puts "#{Bar::Foo::THINGS}!"

Bar::Foo.new.fiz
