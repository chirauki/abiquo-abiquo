Facter.add("abiquo_liquibase") do
	setcode do
		# Check for MySQL command presence
		t1 = Facter::Util::Resolution.exec('/usr/bin/which abiquo-liquibase-update') 
		if not t1.nil? and t1.length > 0
			t = 1
		else 
			# if not present, just asume kinton isn't
			t = 0
		end
	end
end
