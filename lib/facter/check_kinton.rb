Facter.add("kinton_present") do
	setcode do
		# Check for MySQL command presence
		t1 = Facter::Util::Resolution.exec('a=$(/usr/bin/which mysql 2> /dev/null); if [ $? -eq 0 ]; then echo 1; else echo 0; fi')
		if not t1.nil? and t1.eql? "1"
			# If present check for kinton
			t = Facter::Util::Resolution.exec("$(/usr/bin/which mysql) -e 'show databases' | grep kinton")
			if t.nil? 
				t = 0 
			else
				t.length > 0 ? t = 1 : t = 0
			end
		else 
			# if not present, just asume kinton isn't
			t = 0
		end
	end
end
