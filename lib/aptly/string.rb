class String
  def quote
    return '' if self.nil?
    "'" + self.gsub("'", '') + "'"
  end
end
