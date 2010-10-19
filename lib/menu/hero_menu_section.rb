

class HeroMenuSection < MenuSection
  def initialize(hero, content)
    super(hero.name, content)
    @hero = hero
  end
end


