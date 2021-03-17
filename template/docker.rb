describe package('docker-ce') do
  it { should be_installed }
end
describe package('docker-ce-cli') do
  it { should be_installed }
end
describe package('containerd.io') do
  it { should be_installed }
end

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end