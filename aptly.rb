#!/usr/bin/ruby

module Aptly
  extend self

  def exec cmd
    out = %x(#{cmd})
    return out, $?.exitstatus
  end

  def list_mirrors
    mirrors = Array.new
    out, status = exec "aptly mirror list"
    raise AptlyException "Failed to list mirrors" if status != 0

    out.lines.each do |line|
      if line.start_with?(" * ")
        parts = line.split(/\[|\]/)
        mirrors << parts[1] if parts.length == 3
      end
    end

    mirrors
  end

end
