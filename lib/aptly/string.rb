class String
  def to_safe
    return '' if self.nil?
    "'" + self.gsub("'", '') + "'"
  end
end
