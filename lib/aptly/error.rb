class AptlyError < RuntimeError
  attr_accessor :output
  @output = nil

  def initialize msg=nil, output=nil
    @output = output
    super msg
  end
end
