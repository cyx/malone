require "ostruct"

class Malone
  def self.deliveries
    @deliveries ||= []
  end

  def self.deliver(*args)
    deliveries << OpenStruct.new(*args)
  end
end


