test_name "Check if HTTPD is installed and running" do

  # Don't run these tests on the following platform
  confine :except, :platform => 'windows'

  step "Make sure HTTPD is installed" do
    hosts.each do |host|
      # Check if HTTPD is installed
      assert check_for_package(host, 'httpd')
    end
  end

  step "Make sure HTTPD is running" do
    hosts.each do |host|
      on(host, "systemctl is-active httpd") do |result|
        # Check if HTTPD is running
        assert_equal(0, result.exit_code)
      end
    end
  end

end