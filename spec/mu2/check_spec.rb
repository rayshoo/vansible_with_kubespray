require 'spec_helper'

describe command('whoami') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'vagrant' }
end

describe package('docker-ce') do
  it { should be_installed }
end
describe package('docker-ce-cli') do
  it { should be_installed }
end
describe package('containerd.io') do
  it { should be_installed }
end

describe command('cat /etc/group | grep docker') do
  let(:disable_sudo) { true }
  its(:stdout) { should contain('vagrant') }
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe package('pip'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end
describe package('python3-pip'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe package('kubelet') do
  it { should be_installed }
end
describe package('kubectl') do
  it { should be_installed }
end
describe package('kubeadm') do
  it { should be_installed }
end
describe service('kubelet') do
  it { should be_enabled }
  it { should be_running }
end

describe port(9099) do
  it { should be_listening }
end