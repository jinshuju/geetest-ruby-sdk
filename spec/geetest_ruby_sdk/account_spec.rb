RSpec.describe GeetestRubySdk::Account do
  let(:geetest_account) { described_class.new('geetest_id', 'geetest_key') }

  it 'has a version number' do
    expect(GeetestRubySdk::VERSION).not_to be nil
  end

  it 'returns geetest id' do
    expect(geetest_account.geetest_id).to eq 'geetest_id'
  end

  it 'returns geetest key' do
    expect(geetest_account.geetest_key).to eq 'geetest_key'
  end

  describe 'register request' do
    describe 'success request' do
      let(:result) { geetest_account.register }

      before do
        allow(GeetestRubySdk::RegisterRequest).to receive(:get).and_return('challenge')
      end

      it 'gets a challenge' do
        expect(result[:challenge]).to eq 'challenge'
      end

      it 'gets a geetest_id' do
        expect(result[:gt]).to eq 'geetest_id'
      end

      it 'gets a success code' do
        expect(result[:success]).to eq 1
      end
    end

    describe 'failed request' do
      let(:result) { geetest_account.register }

      it 'wont success when challenge is not present' do
        allow(GeetestRubySdk::RegisterRequest).to receive(:get).and_return('')
        expect(result[:success]).to eq 0
      end
    end
  end

  describe 'validate request' do
    describe 'failed request' do
      it 'returns false if validate is not equal to encoded challenge' do
        allow(GeetestRubySdk::ValidateRequest).to receive(:post).and_return('seccode')
        expect(geetest_account.validate?('challenge', 'validate', 'seccode')).to be false
      end

      it 'returns false if seccode is not equal to encoded challenge' do
        allow(GeetestRubySdk::ValidateRequest).to receive(:post).and_return('seccode')
        validate = OpenSSL::Digest::MD5.hexdigest('geetest_keygeetestchallenge')
        expect(geetest_account.validate?('challenge', validate, 'seccode')).to be false
      end

      it 'returns false if seccode is equal to encoded challenge and validate is equal to encoded challenge' do
        seccode = OpenSSL::Digest::MD5.hexdigest('seccode')
        allow(GeetestRubySdk::ValidateRequest).to receive(:post).and_return(seccode)
        validate = OpenSSL::Digest::MD5.hexdigest('geetest_keygeetestchallenge')
        expect(geetest_account.validate?('challenge', validate, 'seccode')).to be true
      end
    end
  end
end
