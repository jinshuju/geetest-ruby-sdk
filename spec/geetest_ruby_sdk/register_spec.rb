RSpec.describe GeetestRubySdk::Register do
  let(:geetest_account) { GeetestRubySdk::Account.new('geetest_id', 'geetest_key') }
  let(:geetest_register) { described_class.new(account: geetest_account) }
  let(:payload) { { gt: geetest_account.geetest_id, json_format: 1 } }
  let(:response_headers) { { 'Content-Type' => 'application/octet-stream; charset=binary' } }

  describe 'failed request' do
    it 'returns success 0 when status is 500' do
      stub_request(:get, 'http://api.geetest.com/register.php').with(query: payload).to_return(
        status: [500, 'Internal Server Error'], headers: response_headers
      )
      expect(geetest_register.register[:success]).to eq 0
    end

    it 'returns challenge when status is 500' do
      stub_request(:get, 'http://api.geetest.com/register.php').with(query: payload).to_return(
        status: [500, 'Internal Server Error'], headers: response_headers
      )
      expect(geetest_register.register[:challenge].size).to eq 32
    end

    it 'returns challenge and set success to 0 when response body not json' do
      stub_request(:get, 'http://api.geetest.com/register.php').with(query: payload).to_return(
        status: [200, 'Ok'], headers: response_headers, body: 'invalid response'
      )
      expect(geetest_register.register[:success]).to eq 0
    end

    it 'raises an register failed error when status is 403' do
      stub_request(:get, 'http://api.geetest.com/register.php').with(query: payload).to_return(
        status: [403, 'Forbidden'], headers: response_headers
      )
      expect { geetest_register.register }.to raise_error RestClient::Forbidden
    end
  end

  describe 'success request' do
    let(:body) { { challenge: '1234' * 8 }.to_json }

    before do
      stub_request(:get, 'http://api.geetest.com/register.php').with(query: payload).to_return(
        status: [200, 'Ok'], headers: response_headers, body: body
      )
    end

    it 'returns encrypted challenge' do
      expected_challenge = OpenSSL::Digest::MD5.hexdigest("#{'1234' * 8}geetest_key")
      result = geetest_register.register
      expect(result[:challenge]).to eq expected_challenge
    end
  end
end
