module Tr8n::Extender
  def extended(mod)
    mod.send(:extend,  self::ClassMethods)
    mod.send(:include, self::InstanceMethods)
  end

  def included(mod)
    mod.send(:extend,  self::ClassMethods)
    mod.send(:include, self::InstanceMethods)
  end
end
