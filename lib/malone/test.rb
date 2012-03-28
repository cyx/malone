require "ostruct"

class Malone
  def self.deliveries
    @deliveries ||= []
  end

  def deliver(*args)
    self.class.deliveries << OpenStruct.new(*args)
  end
end


