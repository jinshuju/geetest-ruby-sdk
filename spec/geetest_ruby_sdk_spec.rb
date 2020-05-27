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
end
