require 'rest-client'

module GeetestRubySdk
  # This class is used internally by GeetestRubySdk to send a validate request
  # => post: to send a post request to geetest service and return if a geetest is valid
  # parameters
  # * :challenge
  # * :validate
  # * :seccode
  # * :options => some options for callback like user_name, password
  class ValidateRequest
    VALIDATE_URL = '/validate.php'

    class << self
      def post(challenge, validate, seccode, options = {})
        payload = {
          challenge: challenge, validate: validate, seccode: seccode, json_format: GeetestRubySdk::JSON_FORMAT
        }
        payload.merge! options
        response = RestClient.post "#{GeetestRubySdk::BASE_URL}#{VALIDATE_URL}", payload
        response_json = JSON.parse response.body
        response_json['seccode']
      rescue JSON::ParserError => e
        GeetestRubySdk.logger.info "Register request failed for #{e.message}"
        raise 'validate request failed'
      end
    end
  end
end
