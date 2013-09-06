require "omnicontacts/parse_utils"
require "omnicontacts/middleware/oauth1"
require "json"

module OmniContacts
  module Importer
    class Twitter < Middleware::OAuth1
      include ParseUtils

      attr_reader :auth_host, :auth_token_path, :auth_path, :access_token_path

      def initialize *args
        super *args
        @auth_host = 'api.twitter.com'
        @auth_path = '/oauth/authorize'
        @auth_token_path = '/oauth/request_token'
      end


      def fetch_contacts_from_token_and_verifier auth_token, auth_token_secret, auth_verifier
        access_token = fetch_access_token(auth_token, auth_token_secret, auth_verifier)
        users = get_users_from_twitter(access_token)
        contacts_from_twitter_users(users)
      end

      private

      def params_to_provider
        {:x_auth_access_type => "read"}
      end

      def get_users_from_twitter(access_token)
        cursor=-1
        count = 100
        response_ids = twitter_response = JSON.parse(access_token.get("/1.1/friends/ids.json?cursor=#{cursor}&&count=#{count}").body)
        if response_ids["errors"]
          raise RuntimeError.exception("Errror retrieving data from Twitter")
        end
        ids = response_ids['ids']
        twitter_response = access_token.get("/1.1/users/lookup.json?user_id=#{ids.join(',')}").body
        twitter_users = JSON.parse(twitter_response)
        twitter_users
      end

      def contacts_from_twitter_users(users)
        contacts = []
        returns contacts if users.empty?
        users.each do |user|
          contact = {:id => nil, :first_name => nil, :last_name => nil, :name => nil, :email => nil, :gender => nil, :birthday => nil, :profile_picture=> nil, :relation => nil}
          contact[:id] = user['screen_name']
          contact[:name] = normalize_name(user['name'])
          contact[:profile_picture] = user['profile_image_url_https']
          contacts << contact
        end
        contacts
      end
    end
  end
end
