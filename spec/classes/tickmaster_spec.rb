require 'spec_helper'

describe 'profile::tickmaster' do
  it { should contain_package('influxdb').with_ensure('present') }
end
