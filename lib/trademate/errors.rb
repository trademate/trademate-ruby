module Trademate
  class Error < StandardError; end
  
  class AuthenticationError < Error; end

  class APIError < Error; end
  
  class NotFoundError < Error; end
end
