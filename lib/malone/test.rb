require "ostruct"

class Malone
  def self.deliveries
    @deliveries ||= []
  end

  def self.reset_deliveries
    @deliveries = nil
  end

  def deliver(*args)
    self.class.deliveries << OpenStruct.new(*args)
  end
end


