$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))
require 'puppet/provider/asadmin'

Puppet::Type.type(:applicationref).provide(:asadmin, :parent =>
  Puppet::Provider::Asadmin) do
  desc "Glassfish application reference support."

  def create
    args = Array.new
    args << 'create-application-ref'
    args << "--target" << @resource[:target] if @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def destroy
    args = Array.new
    args << 'delete-application-ref'
    args << 'target' << @resource[:target] if @resource[:target]
    args << @resource[:name]

    asadmin_exec(args)
  end

  def exists?
    args = Array.new
    args << "list-application-refs"
    args << @resource[:target] if @resource[:target]

    asadmin_exec(args).each do |line|
      return true if @resource[:name] == line.chomp
    end
    return false
  end
end
