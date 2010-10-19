
module JsonHelper
  def self.included(kmod)
    kmod.class_eval <<-EOF
  def self.json_create(o)
    puts "json creating #{kmod}" ; new(*o['data'])
  end
    EOF
  end
  def to_json(*a)
    puts "to_json in #{self.class.name}"
    {
      'json_class' => self.class.name,
      'data' => json_params
    }.to_json(*a)
  end
end
