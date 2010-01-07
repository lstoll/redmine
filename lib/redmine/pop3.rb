require 'net/pop'

module Redmine
  module POP3
    class << self
      def check(pop_options={}, options={})
        host = pop_options[:host] || '127.0.0.1'
        port = pop_options[:port] || '110'

        pop = Net::POP3.new(host,port)

pop.enable_ssl(OpenSSL::SSL::VERIFY_NONE) unless pop_options[:ssl].nil?

        pop.start(pop_options[:username], pop_options[:password]) do |pop_session|
          pop_session.each_mail do |msg|
            message = msg.pop
            logger.debug "Receiving message: #{message.grep(/^Subject: /)}" if logger && logger.debug?
            if MailHandler.receive(message, options)
              logger.info "Message #{message.grep(/^Subject: /)} processed -- removing from server." if logger && logger.info?
              puts "#{message.grep(/^Subject: /)}" 
              puts "--> Message processed and deleted from the server" 
              msg.delete
            else
              puts "#{message.grep(/^Subject: /)}" 
              puts "--> Message NOT processed -- leaving it on the server" 
              logger.info "ERROR: Message #{message.grep(/^Subject: /)} can not be processed, leaving on the server." if logger && logger.info?
            end

          end
        end

      end

      private

      def logger
        RAILS_DEFAULT_LOGGER
      end
    end
  end
end

