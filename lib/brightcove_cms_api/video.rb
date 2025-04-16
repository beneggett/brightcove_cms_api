require "http"
require_relative "errors"

API_URL = "https://cms.api.brightcove.com/v1/accounts"
OAUTH_ENDPOINT = "https://oauth.brightcove.com/v4/access_token"

module BrightcoveCmsApi
  class Video

    def initialize(account_id:, client_id:, client_secret:)
      @account_id = account_id
      @client_id = client_id
      @client_secret = client_secret
      set_authtoken
    end

    # Get Videos
    def find_all
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/videos")
      send_response
    end

    # Create Videos
    def create(params = {})
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").post("#{API_URL}/#{@account_id}/videos", { json: params })
      send_response
    end

    # Get Video count
    def count
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/counts/videos")
      send_response
    end

    # Get Video by id and reference_id
    def get_by_reference_id(video_id)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/videos/#{video_id}")
      send_response
    end

    # delete video
    def delete(video_id)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").delete("#{API_URL}/#{@account_id}/videos/#{video_id}")
      send_response
    end

    # update video
    def update(video_id, params = {})
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").patch("#{API_URL}/#{@account_id}/videos/#{video_id}", { json: params })
      send_response
    end

    # Get video images
    def images(video_id)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/videos/#{video_id}/images")
      send_response
    end

    # get playlists for video
    def playlists(video_id)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/videos/#{video_id}/references")
      send_response
    end

    # remove video from all playlists
    def remove_from_playlists(video_id)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").delete("#{API_URL}/#{@account_id}/videos/#{video_id}/references")
      send_response
    end

    # Get custom fields
    def custom_fields
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").get("#{API_URL}/#{@account_id}/video_fields")
      send_response
    end

    # Ingest Request
    def ingest_request(video_id, params)
      check_token_expires
      @response = HTTP.auth("Bearer #{@token}").post(
        "#{API_URL}/#{@account_id}/videos/#{video_id}/ingest_request",
        { json: params }
      )
      send_response
    end

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
