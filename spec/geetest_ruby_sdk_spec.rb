RSpec.describe GeetestRubySdk do
  it 'has a version number' do
    expect(GeetestRubySdk::VERSION).not_to be nil
  end

  it 'inits an account for geetest sdk when setup' do
    geetest_account = described_class.setup 'geetest_id', 'geetest_key'
    expect(geetest_account.class.name).equal? 'GeetestRubySdk::Account'
  end

  it 'writes log when logger called' do
    expect(described_class.logger.info('This is a message')).equal? 'This is a message'
  end

  describe '#exceptions_to_degraded_mode' do
    it 'includes three default exceptions' do
      expect(GeetestRubySdk.exceptions_to_degraded_mode).to include(RestClient::InternalServerError)
      expect(GeetestRubySdk.exceptions_to_degraded_mode).to include(RestClient::NotFound)
      expect(GeetestRubySdk.exceptions_to_degraded_mode).to include(JSON::ParserError)
    end

    context 'after add new exception' do
      it 'includes added exception' do
        expect do
          GeetestRubySdk.exceptions_to_degraded_mode << RestClient::Forbidden
        end.to change {GeetestRubySdk.exceptions_to_degraded_mode.size}.by(1)
        expect(GeetestRubySdk.exceptions_to_degraded_mode).to include(RestClient::Forbidden)
      end
    end
  end
end
