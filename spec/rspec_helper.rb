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
