require "http"
require_relative "errors"

API_URL = "https://ingest.api.brightcove.com/v1/accounts"
OAUTH_ENDPOINT = "https://oauth.brightcove.com/v4/access_token"

module BrightcoveCmsApi
  class Ingest

    def initialize(account_id:, client_id:, client_secret:)
      @account_id = account_id
      @client_id = client_id
      @client_secret = client_secret
      set_authtoken
    end

    # Ingeset Request
    def ingest_request(video_id, params)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").post(
        "#{API_URL}/#{@account_id}/videos/#{video_id}/ingest_request",
        { json: params }
      )
      send_response
    end

    # Request auto captions
    def request_auto_captions(video_id, srclang:, kind:, label:, default: false)
      params = {
        transcriptions: [
          {
            srclang: srclang,
            kind: kind,
            label: label,
            default: default
          }
        ]
      }
      ingest_request(video_id, params)
    end

    private

      def set_authtoken
        response = HTTP.basic_auth(user: @client_id, pass: @client_secret)
                     .post(OAUTH_ENDPOINT,
                           form: { grant_type: "client_credentials" })
        token_response = response.parse

        if response.status == 200
          @token = token_response.fetch("access_token")
          @token_expires = Time.now + token_response.fetch("expires_in")
        else
          raise AuthenticationError, token_response.fetch("error_description")
        end
      end

      def check_token_expires
        set_authtoken if @token_expires < Time.now
      end

      def send_response
        case @response.code
        when 200, 201, 204
          @response.parse
        else
          raise CmsapiError, @response
        end
      end

  end
end
