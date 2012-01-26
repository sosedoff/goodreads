module Goodreads
  module Users
    # Get user details
    #
    def user(id)
      data = request('/user/show', :id => id)
      Hashie::Mash.new(data['user'])
    end
  end
end