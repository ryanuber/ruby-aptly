class AptlyError < RuntimeError
  attr_accessor :aptly_error, :aptly_output
  @aptly_output = nil
  @aptly_error = nil

  def initialize msg=nil, output=nil, error=nil
    @aptly_output = output
    @aptly_error = error
    super msg
  end
end
