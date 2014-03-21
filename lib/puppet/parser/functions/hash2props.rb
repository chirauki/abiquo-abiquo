module Puppet::Parser::Functions

  newfunction(:hash2props, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Accepts a hash of Abiquo properties and returns a string to be used as content for properties file.
    Also needs which section of the properties file it represents.

    For example:

        $test = hash2props($section, $myhash)
    ENDHEREDOC

    unless args.length == 2
      raise Puppet::ParseError, ("hash2props(): wrong number of arguments (#{args.length}; must be 2)")
    end
    lines = []
    lines << "[#{args[0]}]"
    
    props = args[1]
    props.keys.each do |prop|
      line = "#{prop} = #{props[prop]}"
      lines << line
    end
    lines << ""

    lines.join("\n").sort
  end

end