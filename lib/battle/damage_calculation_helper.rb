
class DamageCalculationHelper
  def calculate_damage(src,dest)
    puts "uh oh, #{src} does 0 damage " if src.damage == 0
    src.damage #TODO take dest defense into account etc
  end
end
