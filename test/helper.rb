require "cutest"
require "flexmock/base"

require File.expand_path("../lib/malone", File.dirname(__FILE__))

class FlexMock
  class CutestFrameworkAdapter
    def assert_block(msg, &block)
      unless yield
        puts msg
        flunk(7)
      end
    end

    def assert_equal(a, b, msg=nil)
      flunk unless a == b
    end

    class AssertionFailedError < StandardError; end

    def assertion_failed_error
      Cutest::AssertionFailed
    end
  end

  @framework_adapter = CutestFrameworkAdapter.new
end

module Cutest::Flexmocked
  def test(*args, &block)
    super

    flexmock_verify
  ensure
    flexmock_close
  end
end

class Cutest::Scope
  include FlexMock::ArgumentTypes
  include FlexMock::MockContainer

  include Cutest::Flexmocked
end