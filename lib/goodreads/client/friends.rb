module Goodreads
  module Friends
    # Get the specified user's friends
    #
    # user_id - integer or string
    #
    def friends(user_id)
      data = oauth_request("/friend/user/#{user_id}")
      Hashie::Mash.new(data['friends'])
    end
  end
end