
class CompositeInteractableSurfaceBackedPallette
  def initialize(configs)
    @backing = {}
    configs.each {|config|
      filename = config[0]
      @backing[filename] = InteractableSurfaceBackedPallette.new(filename, config[1], config[2])
    }
  end

  def []=(key, value)
    @backing[value.filename][key] = value
  end

  def [](key)
    
    @backing.each {|k,v|
      r = v[key]
      return r unless r.nil?
    }
    nil
  end

end
