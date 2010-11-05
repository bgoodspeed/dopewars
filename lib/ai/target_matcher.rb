
class TargetMatcher
  def initialize(target)
    @target = target
  end

  def target_is_enemy?
    @target.downcase.include?("enemy")
  end

  def is_enemy_of?(src,target)
    src.class != target.class
  end
  def matches?(src,target)
    if target_is_enemy?
      return is_enemy_of?(src,target)
    end
    true
  end
end
