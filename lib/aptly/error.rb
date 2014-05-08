class AptlyError < RuntimeError
  attr_accessor :stderr, :stdout
  @stdout = nil
  @stderr = nil

  def initialize msg=nil, out=nil, err=nil
    @stdout = out
    @stderr = err
    super msg
  end
end
