class Hash
  def deep_stringify_hash!(marker = '&&&')
    keys.each do |key|
      new_key = key.to_s
      new_key = marker + new_key if new_key.include?(' ')
      val = self[new_key] = delete(key)
      if val.is_a?(Hash)
        val.deep_stringify_hash!(marker)
      elsif val.is_a?(Array)
        val.deep_stringify_array!(marker)
      elsif !(val.is_a?(Symbol) || val.nil?)
        self[new_key] = marker + val.to_s.gsub(/\n/, ' ') + marker unless skip_key?(new_key) # force quotes on all entries and escape linefeeds
      end
    end
    self
  end

  def deep_traverse(tokens = [])
    stack = self.map { |k, v| [[k], v] }
    while !stack.empty?
      key, value = stack.pop
      tokens << [ key.join('.'), value ]
      if value.is_a? Hash
        value.each { |k,v| stack.push [key.dup << k, v] }
      end
    end
  end
end

class Array
  def deep_stringify_array!(marker = '&&&')
    self.each_with_index do |val, i|
      if val.is_a?(Hash)
        val.deep_stringify_hash!(marker)
      elsif val.is_a?(Array)
        val.deep_stringify_array!(marker)
      elsif !(val.is_a?(Symbol) || val.nil?)
        self[i] = marker + val.to_s.gsub(/\n/,' ') + marker # force quotes on all entries and escape linefeeds
      end
    end
    self
  end
end

def skip_key?(key)
  key && (key.include?('significant') || key == 'precision')
end
