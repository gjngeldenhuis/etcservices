require 'puppetx/filemapper'

Puppet::Type.type(:internet_service).provide(:linux) do

  include PuppetX::FileMapper

  confine  :kernel => 'linux'

  def select_file
    '/etc/services'
  end

  def self.target_files
    ['/etc/services']
  end

  def self.parse_file(filename, contents)
    internetservice_list = []

    lines = contents.split("\n")
    lines.map! { |line| line.sub(/^ *#.*$/, '') }
    lines.reject! { |line| line.match(/^\s*$/) }

    service_regex = /(^[^#\t ]*)[ \t]*(\d*)\/(\w*)[ \t]*([A-Za-z0-9\-\+\t \/]*)?(# *(.*)$)?/

    lines.each do |line|
      if (m = line.match service_regex)
        internetservice_list << {
          :name          => m[1].strip,
          :port          => m[2].strip,
          :protocol      => m[3].strip,
          :service_alias => m[4].to_s.split(' '),
          :comment       => m[6].to_s.strip,
          :file          => filename
        }
      else
        raise Puppet::Error, %{#{filename} is malformed; "#{line}" did not match "#{service_regex.to_s}"}
      end
    end

    internetservice_list
  end

  def self.format_file(filename, providers)
    content = String.new
    providers.each do |provider|

      name = provider.send(:name)
      name = self.format_value(name)

      port_proto = "#{provider.send(:port)}/#{provider.send(:protocol)}"
      port_proto = self.format_value(port_proto)

      service_alias = provider.send(:service_alias)
      if service_alias
        service_alias = self.format_value(service_alias.join(' '))
      end

      comment = provider.send(:comment)
      if comment && comment.length > 0
        comment = "# #{comment}"
      end

      content << "%s%s%s%s\n" % [name,port_proto,service_alias,comment]
    end
    content
  end

  def self.format_value(val)
    col_width = 8
    padding = (val.length/col_width)

    unless padding == 0
      padding = ((padding + 1) * 8)
    else
      padding = 16
    end
    "%-#{padding}s" % val
  end
end
