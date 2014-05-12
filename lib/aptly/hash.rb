class Hash
  def arg arg, default
    if self.has_key? arg
      return self[arg]
    else
      return default
    end
  end
end
