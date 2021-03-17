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