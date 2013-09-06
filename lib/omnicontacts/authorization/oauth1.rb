require "omnicontacts/http_utils"
require "base64"

# This module represent a OAuth 1.0 Client.
#
# Classes including the module must implement
# the following methods:
# * auth_host ->  the host of the authorization server
# * auth_token_path -> the path to query to obtain a request token
# * consumer_key -> the registered consumer key of the client
# * consumer_secret -> the registered consumer secret of the client
# * callback -> the callback to include during the redirection step
# * auth_path -> the path on the authorization server to redirect the user to
# * access_token_path -> the path to query in order to obtain the access token
module OmniContacts
  module Authorization
    module OAuth1
      include HTTPUtils

      OAUTH_VERSION = "1.0"

      # Obtain an authorization token from the server.
      # The token is returned in an array along with the relative authorization token secret.

      def oauth_consumer
        options = { site: "https://#{auth_host}",
                    request_token_path: auth_token_path
        }
        OAuth::Consumer.new(consumer_key, consumer_secret, options)
      end

      def fetch_authorization_token
        request_token = oauth_consumer.
          get_request_token(request_token_req_params, params_to_provider)
        [request_token.token, request_token.secret]
      end

      private

      def params_to_provider
        {}
      end

      def request_token_req_params
        {
          :oauth_callback => callback
        }
      end

      def values_from_query_string query_string, keys_to_extract
        map = query_string_to_map(query_string)
        keys_to_extract.collect do |key|
          if map.has_key?(key)
            map[key]
          else
            raise "No value found for #{key} in #{query_string}"
          end
        end
      end

      public

      # Returns the url the user has to be redirected to do in order grant permission to the client application.
      def authorization_url auth_token
        "https://" + auth_host + auth_path + "?oauth_token=" + auth_token
      end

      # Fetches the access token from the authorization server.
      # The method expects the authorization token, the authorization token secret and the authorization verifier.
      # The result comprises the access token, the access token secret and a list of additional fields extracted from the server's response.
      # The list of additional fields to extract is specified as last parameter
      def fetch_access_token auth_token, auth_token_secret, auth_verifier
        request_token = OAuth::RequestToken.new(oauth_consumer, auth_token, auth_token_secret)
        access_token = request_token.get_access_token(:oauth_verifier => auth_verifier)
        access_token
      end
    end
  end
end
