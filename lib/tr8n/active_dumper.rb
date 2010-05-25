class Tr8n::DumperException < StandardError; end
module Tr8n::ActiveDumper
  extend Tr8n::Extender

  module InstanceMethods
    def _dump(ignored)
      data = {:attributes => @attributes, :new_record => @new_record}
      Marshal.dump(data)
    end
  end
  
  module ClassMethods
    def _load(str)
      data = Marshal.load(str)
      
      raise Tr8n::DumperException, 'invalid format' if not data.kind_of?(Hash) or data.keys.to_set != [:attributes, :new_record].to_set

      instance = new
      instance.instance_variable_set(:@attributes, data[:attributes])
      instance.instance_variable_set(:@new_record, data[:new_record])
      instance
    end
  end
end
