class Neat
  def cool
    foo = 1

    @bar = 2

    @@baz = 3

    $qux = 4

    puts "#{foo} #{@bar} #{@@baz} #{$qux}"
  end
  ::Super::Duper::THINGS = 5
  puts ::Super::Duper::THINGS
end
