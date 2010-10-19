
class ConditionMatcher
  def initialize(cond)
    @condition = cond
  end
  def matches?(src, target)
    puts "condition #{@condition} matches #{target} ?"
    true
  end
end
