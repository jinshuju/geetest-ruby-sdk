RSpec.describe GeetestRubySdk::ValidateRequest do
  describe 'failed request' do
    let(:body) { { seccode: '1234' * 8 }.to_json }

    before do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(
          body: { 'challenge' => 'challenge', 'json_format' => '1', 'seccode' => 'seccode', 'validate' => 'validate' }
        )
        .to_return(
          body: body, status: 400, headers: { 'Content-Type' => 'application/octet-stream; charset=binary' }
        )
    end

    it 'raises an register failed error when status is not 200' do
      expect { described_class.post('challenge', 'validate', 'seccode') }.to \
        raise_error RestClient::BadRequest
    end
  end

  describe 'success request' do
    let(:body) { { seccode: '1234' * 8 }.to_json }

    before do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(
          body: { 'challenge' => 'challenge', 'json_format' => '1', 'seccode' => 'seccode', 'validate' => 'validate' }
        )
        .to_return(
          body: body, status: 200, headers: { 'Content-Type' => 'application/octet-stream; charset=binary' }
        )
    end

    it 'returns seccode' do
      expect(described_class.post('challenge', 'validate', 'seccode')).to eq '1234' * 8
    end
  end
end
