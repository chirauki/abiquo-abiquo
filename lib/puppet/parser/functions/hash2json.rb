module Puppet::Parser::Functions
  newfunction(:hash2json, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Accepts a hash and returns its JSON representation.

    For example:

        $test = hash2json($hash)

    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("hash2json(): wrong number of arguments (#{args.length}; must be 1)")
    end
    
    unless args[0].empty?
      PSON.pretty_generate(args[0])
    else
      "{}"
    end
  end
end