require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Tr8n::Config do
  subject { Tr8n::Config }
  describe 'operator_order' do
    context 'by default' do
      its(:config) {should_not == nil}
    end
  end
end
