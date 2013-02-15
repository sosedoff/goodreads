module Goodreads
  module Groups
    # Get group details
    #
    def group(id)
      data = request('/group/show', :id => id)
      Hashie::Mash.new(data['group'])
    end
  end
end
