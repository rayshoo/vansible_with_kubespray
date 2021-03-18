describe service('kubelet') do
  it { should be_enabled }
  it { should be_running }
end

describe port(9099) do
  it { should be_listening }
end