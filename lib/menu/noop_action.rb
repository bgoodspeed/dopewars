
class NoopAction
  def perform(src,dest)
    puts "nothing to do, noop action" #TODO consume readiness?
  end
end
