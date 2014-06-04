Puppet::Type.newtype(:internet_service) do
  @doc = <<-EOS
    This type allow an abbility to set names for network services.
  EOS

  ensurable
  newparam(:name, :namevar => true) do
  end

  newproperty(:port) do
    desc "Port number"
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:service_aliases, :array_matching => :all) do
    desc "Aliases for service."
  end

  newproperty(:comment) do
    desc "Comment that will be appended to entry."
  end

  newproperty(:protocol, :namevar => true) do
    desc "Should contain protocol for which this port is valid. Normally tcp or udp"
    # make it all lower case
  end

end
