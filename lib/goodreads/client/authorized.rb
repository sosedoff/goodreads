module Goodreads
  module Authorized

    def user_id
      oauth_request('/api/auth_user')['user']['id']
    end

  end
end
