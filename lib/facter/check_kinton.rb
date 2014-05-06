Facter.add("kinton_present") do
	setcode do
		# Check for MySQL command presence
		t1 = Facter::Util::Resolution.exec('/usr/bin/which mysql') 
		if not t1.nil? and t1.length > 0
			# If present check for kinton
			t = Facter::Util::Resolution.exec("#{t1} -e 'show databases' | grep kinton")
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
