RSpec.describe 'Geetest::DegradedMode' do
  let(:account) { Geetest::Account.new('geetest_id', 'geetest_key') }
  let(:register) { Geetest::Register.new(account: account) }
  let(:validator) { Geetest::Validator.new(account: account) }

  describe '#degraded_challenge' do
    it 'length is 32' do
      expect(register.degraded_challenge.length).to eq(32)
    end

    it 'contains timestamp under base36' do
      Timecop.freeze do
        expect(register.degraded_challenge).to include(Time.now.to_i.to_s(36))
      end
    end
  end

  describe '#degraded?' do
    it 'returns false if challenge length invalid' do
      expect(validator.degraded?('challenge')).to be_falsey
    end

    it 'returns false if challenge is faked' do
      challenge = [*'a'..'z', *'0'..'9'].sample(32).join
      expect(validator.degraded?(challenge)).to be_falsey
    end

    it 'return false if challenge created more than 36*36*2 seconds' do
      challenge = register.degraded_challenge
      Timecop.travel(Time.now + 2592) do
        expect(validator.degraded?(challenge)).to be_falsey
      end
    end

    it 'return true if challenge created under degraded model ' do
      challenge = register.degraded_challenge
      expect(validator.degraded?(challenge)).to be_truthy
    end

    it 'return true if challenge created less than 36*36 seconds' do
      challenge = register.degraded_challenge
      Timecop.travel(Time.now + 1296) do
        expect(validator.degraded?(challenge)).to be_truthy
      end
    end
  end
end