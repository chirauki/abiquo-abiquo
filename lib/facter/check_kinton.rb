Facter.add("kinton_present") do
  setcode do
    t = Facter::Util::Resolution.exec('/usr/bin/mysql -e "show databases" | grep kinton')
    t.length > 0
  end
end