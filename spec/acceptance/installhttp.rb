
test_name "install and running HTTPD" do

	#Not install script on following platforms
	confine :except, :platform => 'windows'

	step "Install HTTPD" do
		hosts.each do |hosts|
			install_package(host, 'httpd') unless check_for_package(host, 'httpd')	
		end
	end

	step 'start HTTPD' do 
		hosts.each do |host|
			on(host, "service httpd restart")
		end
	end

end