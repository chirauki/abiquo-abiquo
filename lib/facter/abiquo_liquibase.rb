Facter.add("abiquo_liquibase") do
	setcode do
		# Check for MySQL command presence
		Facter::Util::Resolution.exec('a=$(/usr/bin/which abiquo-liquibase-update 2> /dev/null); if [ $? -eq 0 ]; then echo 1; else echo 0; fi') 
	end
end
