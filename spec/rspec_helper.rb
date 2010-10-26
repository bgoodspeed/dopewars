require 'rubygems'

require 'rubygame'
require 'json'
require 'forwardable'

require 'lib/game_settings'
require 'lib/game_requirements'

module MockeryHelp
  def mocking(conf)
    m = mock
    conf.each {|k,v| m.stub!(k).and_return(v) }
    m
  end
end


module DelegationMatchers
  class DelegateToMatcher
    def initialize(sym_and_args, config)
      @sym = sym_and_args.keys[0]
      @args = sym_and_args.values[0]

      @exp_delegate = config.keys[0]
      @exp_delegate_method = config.values[0]
    end

    def matches?(target)
      m = Spec::Mocks::Mock.new("mock for #{target}.#{@exp_delegate}")
      m.should_receive(@exp_delegate_method).with(*@args)
      target.send("#{@exp_delegate}=", m)
      target.send(@sym, *@args)
      m
    end

    def failure_message_for_should
      "idano, you failed, whatever"
    end
    def failure_message_for_should_not
      "idano, you failed, whatever"
    end

  end

  def delegate_to(sym, config)
    DelegateToMatcher.new(sym, config)
  end

end


module WorldMapMatchers
  class NearEnoughToMatcher
    @@NEARNESS_THRESHOLD= 1.5
    def initialize(base)
      @base = base
    end

    def cmp_axis(idx, target)
      error = (@base[idx] - target[idx]).abs
      error < @@NEARNESS_THRESHOLD
    end

    def matches?(target)
      @target = target
      cmp_axis(0, target) && cmp_axis(1, target)
    end

    def fmt(array)
      array.join(",")
    end

    def failure_msg(is_not="")
      "#{fmt(@base)} expected #{is_not} to be within #{@@NEARNESS_THRESHOLD} of #{fmt(@target)}"
    end
    def failure_message_for_should
      failure_msg
    end
    def failure_message_for_should_not
      failure_msg("not")
    end

  end

  def be_near_enough_to(base)
    NearEnoughToMatcher.new(base)
  end

end


module UtilityMatchers
  class ContainingMatcher
    @@NEARNESS_THRESHOLD= 1.5
    def initialize(base)
      @base = base
    end

    def matches?(target)
      target.include?(@base)
      @target = target
    end

    def fmt(array)
      array.join(",")
    end

    def failure_msg(is_not="")
      "#{fmt(@base)} expected #{is_not} to contain #{fmt(@target)}"
    end
    def failure_message_for_should
      failure_msg
    end
    def failure_message_for_should_not
      failure_msg("not")
    end

  end

  def contain?(base)
    ContainingMatcher.new(base)
  end

end
