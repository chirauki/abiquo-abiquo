require 'json'

module Puppet::Parser::Functions

  newfunction(:stringsum, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Returns the ruby String#sum value for the given string

    For example:

        $test = stringsum("somevalue")
    ENDHEREDOC

    unless args.length == 1
      raise Puppet::ParseError, ("hash2props(): wrong number of arguments (#{args.length}; must be 1)")
    end

    args[0].to_s.sum
  end

end