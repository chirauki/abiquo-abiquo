require 'json'

module Puppet::Parser::Functions

  newfunction(:jsonreplace, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Reads a JSON file, replaces the given key value for the supplied value and returns
    the resulting JSON as a string.

    For example:

        $test = jsonreplace($file, "somekey", "somevalue")
    ENDHEREDOC

    unless args.length == 3
      raise Puppet::ParseError, ("hash2props(): wrong number of arguments (#{args.length}; must be 3)")
    end

    if File.exists?(args[0]) 
      json = File.read(args[0])
      jsonp = JSON.parse(json)

      jsonp[args[1]] = args[2]

      JSON.pretty_generate(jsonp)
    else
      "{}"
    end
  end

end