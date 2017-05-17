require 'spec_helper'

describe 'ambari' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "ambari class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('ambari::params') }
          it { is_expected.to contain_class('ambari::agent_install').that_comes_before('ambari::config') }
          it { is_expected.to contain_class('ambari::agent_config') }
          it { is_expected.to contain_class('ambari::agent_service').that_subscribes_to('ambari::config') }

          it { is_expected.to contain_service('ambari-agent') }
          it { is_expected.to contain_package('ambari-agent').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'ambari class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('ambari') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
