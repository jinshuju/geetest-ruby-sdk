RSpec.describe Geetest do
  let(:config) { { id: "geetest_id", key: "geetest_key" } }
  let(:login_config) { { id: "geetest_login_id", key: "geetest_login_key", channel: "login" } }
  let(:submit_config) { { id: "geetest_submit_id", key: "geetest_submit_key", channel: "submit" } }

  before do
    Geetest.instance_variables.each(&Geetest.method(:remove_instance_variable))
  end

  it 'inits an account for geetest sdk when setup' do
    geetest_account = described_class.setup id: 'geetest_id', key: 'geetest_key'
    expect(geetest_account.class.name).equal? 'GeetestRubySdk::Account'
  end

  it 'writes log when logger called' do
    expect(described_class.logger.info('This is a message')).equal? 'This is a message'
  end


  describe "#setup" do
    it "succeeds when given a config hash" do
      expect(described_class.setup(config)).to be_a Geetest::V3::Account
    end

    it "succeeds when given a channel_name and a config hash" do
      expect(described_class.setup(config.merge(channel: :normal))).to be_a Geetest::V3::Account
    end

    it "succeeds when given channel_name and append config hash by #with" do
      expect(described_class.setup(:normal).with(config)).to be_a Geetest::V3::Account
    end
  end

  describe "#channels" do
    context 'if setup without channel_name' do
      it 'returns an account instance' do
        expect(described_class.setup(config)).to be_a Geetest::V3::Account
      end

      it 'can get the account instance by #channel' do
        account_instance = described_class.setup(config)
        expect(described_class.channel).to eq account_instance
      end
    end

    context 'if setup without channel_name' do
      context 'if setup without channel_name' do
        it 'returns an account instance' do
          expect(described_class.setup(config)).to be_a Geetest::V3::Account
        end

        it 'can get the account instance by #channel' do
          account = described_class.setup(config)
          expect(described_class.channel).to eq account
        end
      end

      context 'if setup with channel_name' do
        it 'returns an account instance' do
          account_for_login = described_class.setup(login_config)
          expect(account_for_login).to be_a Geetest::V3::Account
        end

        it 'can get the account instance by channel_name' do
          account_for_login = described_class.setup(login_config)
          account_for_submit = described_class.setup(submit_config)
          expect(described_class.channel(:login)).to eq account_for_login
          expect(described_class.channel(:submit)).to eq account_for_submit
        end
      end
    end
  end

  describe '#exceptions_to_degraded_mode' do
    it 'includes three default exceptions' do
      expect(described_class.exceptions_to_degraded_mode).to include(RestClient::InternalServerError)
      expect(described_class.exceptions_to_degraded_mode).to include(RestClient::NotFound)
      expect(described_class.exceptions_to_degraded_mode).to include(JSON::ParserError)
    end

    context 'after add new exception' do
      it 'includes added exception' do
        expect do
          described_class.exceptions_to_degraded_mode << RestClient::Forbidden
        end.to change { described_class.exceptions_to_degraded_mode.size }.by(1)
        expect(described_class.exceptions_to_degraded_mode).to include(RestClient::Forbidden)
      end
    end
  end
end
