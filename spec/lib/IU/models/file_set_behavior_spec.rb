require 'rails_helper'

describe Concerns::FileSetBehavior do

  before do
    class TestClass < ActiveFedora::Base
      include Concerns::FileSetBehavior
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end
end
