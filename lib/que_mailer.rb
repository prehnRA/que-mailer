module Que
  module Mailer
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
      
      def deliver?
        true
      end
    end
    module ClassMethods   
      def current_env
        if defined?(Rails)
          ::Que::Mailer.current_env || ::Rails.env
        else
          ::Que::Mailer.current_env
        end
      end
      
      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          MessageDecoy.new(self, method_name, *args)
        else
          super
        end
      end
      
      def perform(action, *args)
        begin
          message = self.send(:new, action, *args).message
          message.deliver
        rescue Exception => ex
          if logger
            logger.error "Unable to deliver email [#{action}]: #{ex}"
            logger.error ex.backtrace.join("\n\t")
          end
        end
          
        raise ex
      end
      
      def deliver?
        true
      end
    end
    
    class MailJob < Que::Job
      def run(mailer_class, method_name, *args)
        mailer = Kernel.const_get(mailer_class)
        mailer.send(method_name, *args).deliver!
      end
    end
    
    class MessageDecoy
      delegate :to_s, :to => :actual_message
      
      def initialize(mailer_class, method_name, *args)
        @mailer_class = mailer_class
        @method_name = method_name
        *@args = *args
        @actual_message
      end
      
      def current_env
        if defined?(Rails)
          ::Que::Mailer.current_env || ::Rails.env
        else
          ::Que::Mailer.current_env
        end
      end
      
      def actual_message
        @actual_message ||= @mailer_class.send(:new, @method_name, *@args).message
      end
           
      def deliver
        if @mailer_class.deliver?
          MailJob.queue(@mailer_class.to_s, @method_name, *@args)
        end
      end
      
      def deliver_at(time)
        if @mailer_class.deliver?
          MailJob.queue(actual_message, :run_at => time)
        end
      end
      
      def deliver_in(time)
        deliver_at(time.from_now)
      end
      
      def deliver!
        actual_message.deliver
      end
      
      def method_missing(method_name, *args)
        actual_message.send(method_name, *args)
      end
      
      def logger
        @mailer_class.logger
      end
    end
  end
end