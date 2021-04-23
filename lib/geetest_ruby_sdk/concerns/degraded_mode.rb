# frozen_string_literal: true

module GeetestRubySdk
  # Create and validate a challenge under degraded model
  # When a degraded_challenge is created, it will keep valid at least in 21.6 minutes and no more than 43.2 minutes
  # 21.6 = 36 * 36 / 60 (that means the last 2 chars of base36 timestamp)
  # By default, the validity of geetest challenge is 10 minutes, so 21.6 minutes is enough in degraded model.
  module DegradedMode
    CHALLENGE_LENGTH = 32

    def degraded_challenge
      timestamp = Time.now.to_i.to_s(36)
      index = rand(20..26)
      random = [*'a'..'z', *'0'..'9'].sample(6).join
      sha = Encryptor.encrypt(timestamp).with(account.geetest_key).by(digest_mod).to_challenge
      (sha[0,index] + timestamp).ljust(CHALLENGE_LENGTH, random)
    end

    def degraded?(challenge)
      return false unless challenge.length == CHALLENGE_LENGTH

      valid_marks = [Time.now.to_i, Time.now.to_i - 36 * 36].map { |t| t.to_s(36)[0,4] }
      valid_marks.any? do |mark|
        index = challenge.index(mark)
        next unless (20..26).include?(index)

        timestamp = challenge[index,6]
        sha = Encryptor.encrypt(timestamp).with(account.geetest_key).by(digest_mod).to_challenge
        sha[0, index] == challenge[0, index]
      end
    end
  end
end