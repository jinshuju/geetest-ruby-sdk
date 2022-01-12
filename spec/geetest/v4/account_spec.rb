RSpec.describe Geetest::V4::Account do
  let(:geetest_account) { described_class.new('geetest_id', 'geetest_key') }

  it 'returns geetest id' do
    expect(geetest_account.captcha_id).to eq 'geetest_id'
  end

  it 'returns geetest key' do
    expect(geetest_account.captcha_key).to eq 'geetest_key'
  end

  it 'returns geetest api_server' do
    expect(geetest_account.api_server).to be_a URI
    expect(geetest_account.api_server.to_s).to eq Geetest::V4::Account::DEFAULT_API_SERVER
  end

  describe 'validate' do
    let(:geetest_data) do
      {
        lot_number: 'lot_number',
        captcha_output: 'captcha_output',
        pass_token: 'pass_token',
        gen_time: 'gen_time'
      }
    end
    let(:request_payload) do
      geetest_data.merge(sign_token: '5ab251a6730b35e2895d8ce5e85d596e9a3dc7139990844976f785f002b8fdb9')
    end
    let(:validate_url) { 'http://gcaptcha4.geetest.com/validate?captcha_id=geetest_id' }

    it 'returns true' do
      stub_request(:post, validate_url).with(body: request_payload).to_return(
        body: { result: 'success', reason: '' }.to_json, status: 200
      )
      expect(geetest_account.validate?(geetest_data)).to be true
    end

    it 'returns false if geetest server return false' do
      stub_request(:post, validate_url).with(body:request_payload).to_return(
        body: { result: 'fail', reason: 'reason' }.to_json, status: 200
      )
      expect(geetest_account.validate?(geetest_data)).to be false
    end

    it 'return true if request geetest api fail' do
      stub_request(:post, validate_url).with(body:request_payload).to_return(
        body: 'Internal Server Error', status: 500
      )
      expect(geetest_account.validate?(geetest_data)).to be true
    end

    it 'returns false if request geetest api fail and exception not in degraded_mode' do
      stub_request(:post, validate_url).with(body: request_payload).to_return(
        body: 'Forbidden', status: 403
      )
      expect { geetest_account.validate?(geetest_data) }.to raise_error RestClient::Forbidden
    end
  end
end
