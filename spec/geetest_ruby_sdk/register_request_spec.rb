RSpec.describe GeetestRubySdk::RegisterRequest do
  describe 'failed request' do
    let(:body) { { challenge: 123.to_s }.to_json }

    it 'wont success when challenge is not 32' do
      stub_request(:get, 'http://api.geetest.com/register.php?gt=geetest_id&json_format=1')
        .to_return(
          body: body, status: 200, headers: { 'Content-Type' => 'application/octet-stream; charset=binary' }
        )
      expect(described_class.get('geetest_id', 'geetest_key')).to be nil
    end

    it 'raises an register failed error when status is not 200' do
      stub_request(:get, 'http://api.geetest.com/register.php?gt=geetest_id&json_format=1')
        .to_return(
          body: body, status: 400, headers: { 'Content-Type' => 'application/octet-stream; charset=binary' }
        )
      expect { described_class.get('geetest_id', 'geetest_key') }.to raise_error RestClient::BadRequest
    end
  end

  describe 'success request' do
    let(:body) { { challenge: '1234' * 8 }.to_json }

    before do
      stub_request(:get, 'http://api.geetest.com/register.php?gt=geetest_id&json_format=1')
        .to_return(
          body: body, status: 200, headers: { 'Content-Type' => 'application/octet-stream; charset=binary' }
        )
    end

    it 'returns encrypted challenge' do
      expected_challenge = OpenSSL::Digest::MD5.hexdigest("#{'1234' * 8}geetest_key")
      expect(described_class.get('geetest_id', 'geetest_key')).to eq expected_challenge
    end
  end
end
