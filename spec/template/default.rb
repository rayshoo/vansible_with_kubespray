require 'spec_helper'

describe command('whoami') do
  let(:disable_sudo) { true }
  its(:stdout) { should match 'vagrant' }
end