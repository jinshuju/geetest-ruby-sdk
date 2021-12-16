RSpec.describe Geetest::Validator do
  let(:geetest_account) { Geetest::Account.new('geetest_id', 'geetest_key') }
  let(:geetest_validator) { described_class.new(account: geetest_account) }
  let(:challenge) { 'challenge' }
  let(:validate) { OpenSSL::Digest::MD5.hexdigest('geetest_keygeetestchallenge') }
  let(:seccode) { 'seccode' }
  let(:request_body) { { challenge: challenge, json_format: '1', seccode: seccode, validate: validate } }
  let(:response_body) { { seccode: OpenSSL::Digest::MD5.hexdigest('seccode') }.to_json }
  let(:response_headers) { { 'Content-Type' => 'application/octet-stream; charset=binary' } }

  describe 'validate' do
    it 'returns false if validate is invalid' do
      expect(geetest_validator.valid?(challenge, 'invalid validate', seccode)).to be false
    end

    it 'requests geetest server if validate is valid' do
      stub = stub_request(:post, 'http://api.geetest.com/validate.php').with(body: request_body).to_return(
        body: response_body, status: 200, headers: response_headers
      )
      geetest_validator.valid?(challenge, validate, seccode)
      expect(stub).to have_been_requested.once
    end

    it 'returns false if seccode is invalid' do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(body: request_body.merge(seccode: 'invalid seccode'))
        .to_return(body: response_body, status: 200, headers: response_headers)
      expect(geetest_validator.valid?(challenge, validate, 'invalid seccode')).to be false
    end

    it 'raises an error when status is not 200' do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(body: request_body)
        .to_return(status: 400, headers: response_headers)
      expect { geetest_validator.valid?(challenge, validate, seccode) }.to raise_error RestClient::BadRequest
    end

    it 'raises an error when response is not a json' do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(body: request_body)
        .to_return(body: 'body', status: 200, headers: response_headers)
      expect { geetest_validator.valid?(challenge, validate, seccode) }.to raise_error JSON::ParserError
    end

    it 'returns true if all params are valid' do
      stub_request(:post, 'http://api.geetest.com/validate.php')
        .with(body: request_body)
        .to_return(body: response_body, status: 200, headers: response_headers)
      expect(geetest_validator.valid?(challenge, validate, seccode)).to be_truthy
    end

    it 'returns true under degraded model' do
      challenge = geetest_validator.degraded_challenge
      validate = OpenSSL::Digest::MD5.hexdigest(challenge)
      expect(geetest_validator.valid?(challenge, validate, seccode)).to be_truthy
    end

    it 'returns false under degraded model but validate is fake' do
      challenge = geetest_validator.degraded_challenge
      validate = OpenSSL::Digest::MD5.hexdigest('fake')
      expect(geetest_validator.valid?(challenge, validate, seccode)).to be_falsey
    end
  end
end
