require 'spec_helper'

describe Puppet::Type.type(:log_level).provider(:asadmin) do

  before :each do
    Puppet::Type.type(:log_level).stubs(:defaultprovider).returns described_class
    #File.expects(:exists?).with('/tmp/test.war').returns(:true).once
    Puppet.features.expects(:root?).returns(true).once
  end

  let :log_level do
    Puppet::Type.type(:log_level).new(
      :name           => 'com.sun.enterprise.server.logging.GFFileHandler.formatter',
      :ensure         => :present,
      :value          => 'com.sun.enterprise.server.logging.UniformLogFormatter',
      :user           => 'glassfish',
      :portbase       => '8000',
      :asadminuser    => 'admin',
      :provider       => provider
    )
  end

  let :provider do
    described_class.new(
      :name => 'com.sun.enterprise.server.logging.GFFileHandler.formatter'
    )
  end

  describe "when asking exists?" do
    it "should return true if resource value matches" do
      log_level.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-log-levels server\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.flushFrequency\t<1>
com.sun.enterprise.server.logging.GFFileHandler.formatter\t<com.sun.enterprise.server.logging.UniformLogFormatter>
com.sun.enterprise.server.logging.GFFileHandler.logtoConsole\t<false>")
      log_level.provider.should be_exists
    end

    it "should return false if resource value doesn't match" do
      log_level.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-log-levels server\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.flushFrequency\t<1>
com.sun.enterprise.server.logging.GFFileHandler.formatter\t<com.sun.enterprise.server.logging.UniformLogFormat>
com.sun.enterprise.server.logging.GFFileHandler.logtoConsole\t<false>")
      log_level.provider.should_not be_exists
    end

    it "should support querying for cluster resources" do
      log_level[:target] = 'cluster'
      log_level.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin list-log-levels cluster\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.flushFrequency\t<1>
com.sun.enterprise.server.logging.GFFileHandler.formatter\t<com.sun.enterprise.server.logging.UniformLogFormat>
com.sun.enterprise.server.logging.GFFileHandler.logtoConsole\t<false>")
      log_level.provider.should_not be_exists
    end
  end

  describe "when creating a resource" do
    it "should be able to set a log_level without a target" do
      log_level[:value] = 'blah'
      log_level.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin set-log-levels --target server com.sun.enterprise.server.logging.GFFileHandler.formatter=blah\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.formatter logging level set with value blah.
        These logging levels are set for server.
        Command set-log-levels executed successfully.")
      log_level.provider.create
    end

    it "should be able to set a log_level with a target" do
      log_level[:value] = 'blah'
      log_level[:target] = 'cluster'
      log_level.provider.expects("`").
        with("su - glassfish -c \"asadmin --port 8048 --user admin set-log-levels --target cluster com.sun.enterprise.server.logging.GFFileHandler.formatter=blah\"").
        returns("com.sun.enterprise.server.logging.GFFileHandler.formatter logging level set with value blah.
        These logging levels are set for cluster.
        Command set-log-levels executed successfully.")
      log_level.provider.create
    end
  end
end
