class Apple
  def self.stir
    @@cvar = :ok
  end

  def sauce
    lvar = :woah
    @ivar = :neat
    puts "#{@ivar} #{lvar}"
  end
end

Recipe.new(ingredients: [Apple.new])
