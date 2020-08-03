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

  describe 'register' do
    let(:url) { 'http://api.geetest.com/register.php' }
    let(:success_result) do
      { challenge: OpenSSL::Digest::MD5.hexdigest('challengegeetest_key'), gt: 'geetest_id', success: 1 }
    end

    it 'returns a success result' do
      stub_request(:get, url)
        .with(query: { gt: geetest_account.geetest_id, json_format: 1 })
        .to_return(status: [200, 'OK'], body: { challenge: 'challenge' }.to_json)
      expect(geetest_account.register).to eq success_result
    end

    it 'returns success 0 when geetest sever return 500' do
      stub_request(:get, url)
        .with(query: { gt: geetest_account.geetest_id, json_format: 1 })
        .to_return(status: [500, 'Internal Server Error'])
      result = geetest_account.register
      expect(result[:success]).to eq 0
    end
  end

  describe 'validate' do
    let(:url) { 'http://api.geetest.com/validate.php' }

    it 'returns false if validate is not equal to encoded challenge' do
      expect(geetest_account.validate?('challenge', 'validate', 'seccode')).to be false
    end

    it 'returns false if encoded seccode is not equal to geetest server return' do
      stub_request(:post, url).with(body: hash_including({})).to_return(
        body: { seccode: 'seccode' }.to_json, status: 200
      )
      validate = OpenSSL::Digest::MD5.hexdigest('geetest_keygeetestchallenge')
      expect(geetest_account.validate?('challenge', validate, 'seccode')).to be false
    end

    it 'returns true if all params are valid' do
      stub_request(:post, url).with(body: hash_including({})).to_return(
        body: { seccode: OpenSSL::Digest::MD5.hexdigest('seccode') }.to_json, status: 200
      )
      validate = OpenSSL::Digest::MD5.hexdigest('geetest_keygeetestchallenge')
      expect(geetest_account.validate?('challenge', validate, 'seccode')).to be true
    end
  end

  describe 'local validate' do
    it 'returns false if validate is not equal to encoded challenge' do
      expect(geetest_account.local_validate?('challenge', 'validate')).to be false
    end

    it 'returns true if validate is equal to encoded challenge' do
      validate = OpenSSL::Digest::MD5.hexdigest('challenge')
      expect(geetest_account.local_validate?('challenge', validate)).to be true
    end
  end
end
