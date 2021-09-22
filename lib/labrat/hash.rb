class Hash
  # Transform hash keys to symbols suitable for calling as methods, i.e.,
  # translate any hyphens to underscores.  This is the form we want to keep
  # config hashes in Labrat.
  def methodize
    transform_keys { |k| k.to_s.gsub('-', '_').to_sym }
  end

  # Convert the given Hash into a Array of Strings that represent an
  # equivalent set of command-line args and pass them into the #parse method.
  def optionize
    options = []
    each_pair do |k, v|
      key = k.to_s.gsub('_', '-')
      options <<
        if [TrueClass, FalseClass].include?(v.class)
          v ? "--#{key}" : "--no-#{key}"
        else
          "--#{key}=#{v}"
        end
    end
    options
  end
end
