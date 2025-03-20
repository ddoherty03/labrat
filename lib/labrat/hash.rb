# frozen_string_literal: true

class Hash
  # Convert the given Hash into a Array of Strings that represent an
  # equivalent set of command-line args and pass them into the #parse method.
  def optionize
    options = []
    each_pair do |k, v|
      key = k.to_s.tr('_', '-')
      options <<
        if [TrueClass, FalseClass].include?(v.class)
          v ? "--#{key}" : "--no-#{key}"
        else
          "--#{key}=#{v}"
        end
    end
    options
  end

  def report(title)
    warn "#{title}:"
    if empty?
      warn "  [[Empty]]"
    else
      each do |k, v|
        val = v.class == Float ? v.round(2).to_s + 'pt' : v
        warn "  #{k}: #{val}"
      end
    end
    warn ""
  end
end
