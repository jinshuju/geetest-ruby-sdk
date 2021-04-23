RSpec.describe GeetestRubySdk::Encryptor do
  describe '#to_challenge' do
    it 'encrypts with md5' do
      challenge = described_class.encrypt('abc').with('secret').by('md5').to_challenge
      expect(challenge).to eq('33e7cb694fb6fb2f848af6774d9ff138')
    end

    it 'encrypts with sha256' do
      challenge = described_class.encrypt('abc').with('secret').by('sha256').to_challenge
      expect(challenge).to eq('a42178b773273f5c9f24387fbea546af537d08b8c06b23631e44878b9ce47f49')
    end

    it 'encrypts with hmac_sha256' do
      challenge = described_class.encrypt('abc').with('secret').by('hmac_sha256').to_challenge
      expect(challenge).to eq('bccfef5d5be31f2b21f4de58488f7ef66f9ddcbe4a54b6bb822606a72da16d79')
    end
  end

  describe '#to_validate' do
    it 'encrypts with md5' do
      validate = described_class.encrypt('abc').with('secret').by('md5').to_validate
      expect(validate).to eq('94801d8bae3293bdb383accf02ee2e65')
    end

    it 'encrypts with sha256' do
      validate = described_class.encrypt('abc').with('secret').by('sha256').to_validate
      expect(validate).to eq('c4be1b7191778160998c5cbc2d9ecab5c8f2709d490c8d64ae7cd7fcde1a32f0')
    end

    it 'encrypts with hmac_sha256' do
      validate = described_class.encrypt('abc').with('secret').by('hmac_sha256').to_validate
      expect(validate).to eq('2d05bd7a4887638634386b48b8348b0cb83412b20040197229039eb845d9b47d')
    end
  end

  describe '#to_s' do
    it 'encrypts with md5' do
      string = described_class.encrypt('abc').by('md5').to_s
      expect(string).to eq('900150983cd24fb0d6963f7d28e17f72')
    end

    it 'encrypts with sha256' do
      string = described_class.encrypt('abc').by('sha256').to_s
      expect(string).to eq('ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad')
    end

    it 'encrypts with hmac_sha256' do
      string = described_class.encrypt('abc').with('secret').by('hmac_sha256').to_s
      expect(string).to eq('9946dad4e00e913fc8be8e5d3f7e110a4a9e832f83fb09c345285d78638d8a0e')
    end
  end
end
