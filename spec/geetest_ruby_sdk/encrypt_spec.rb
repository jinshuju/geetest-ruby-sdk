RSpec.describe GeetestRubySdk::Encrypt do
  it 'encrypts with md5 when digest_mod is not available' do
    expect(described_class.encrypt_with('abc')).to eq OpenSSL::Digest::MD5.hexdigest('abc')
  end

  it 'encrypts with sha256 if digest_mod is sha256' do
    expect(described_class.encrypt_with('abc', 'sha256')).to eq \
      OpenSSL::Digest::SHA256.hexdigest('abc')
  end

  it 'encrypts with hmac_sha256 if digest_mod is hmac_sha256' do
    expect(described_class.encrypt_with('abc', 'hmac_sha256', 'geetest_key')).to eq \
      OpenSSL::HMAC.hexdigest('SHA256', 'geetest_key', 'abc')
  end

  it 'encrypts md5 when mod is not in the list' do
    expect(described_class.encrypt_with('abc', 'md4')).to eq OpenSSL::Digest::MD5.hexdigest('abc')
  end
end
