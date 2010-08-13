require 'postmark'
require 'action_mailer'

module PostmarkMethods
  def perform_delivery_postmark(message)
    Postmark.send_through_postmark(message)
  end

  def tag(value)
    @tag = value
  end

  def attachments(value)
    value = [value] unless value.is_a?(Array)
    @attachments = value.collect{|item|
      if item.is_a?(Hash)
        item
      elsif item.is_a?(File)
        {
          "Name" => item.path.split("/")[-1],
          "Content" => [IO.read(item.path)].pack("m"),
          "ContentType" => "application/octet-stream"
        }
      end
    }
  end
  

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      alias_method_chain :create_mail, :tag
    end
  end

  def create_mail_with_tag
    returning create_mail_without_tag do |mail|
      mail.tag = @tag if @tag
      mail.attachments = @attachments if @attachments
    end
  end

  module ClassMethods
    def postmark_api_key=(value)
      Postmark.api_key = value
    end
  end

end

class ActionMailer::Base
  include PostmarkMethods
end
