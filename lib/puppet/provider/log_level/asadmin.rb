$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:log_level).provide(:asadmin, :parent =>
                                      Puppet::Provider::Asadmin) do
  desc "Glassfish domain log level support."

  def create
    args = Array.new
    args << 'set-log-levels'
    args << "--target" << @resource[:target] if @resource[:target]
    args << "#{@resource[:name]}=#{@resource[:value]}"
    asadmin_exec(args)
  end

  def destroy
    # Destroy can't do anything with log_attribute.
  end

  def exists?
    args = Array.new
    args << 'list-log-levels'
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if "#{@resource[:name]}\t<#{@resource[:value]}>" == line.chomp
    end
    return false
  end
end
