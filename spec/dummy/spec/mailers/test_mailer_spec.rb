require 'spec_helper'

describe Que::Mailer do
  it "should send mail" do
    QueJob.count.should be 0
    
    ActionMailer::Base.deliveries.length.should be 0
    TestMailer.test_message.deliver
    QueJob.count.should be 1
    
    TestMailer::MailJob.work
    ActionMailer::Base.deliveries.length.should be 1
    QueJob.count.should be 0
  end
  
  it "should send delayed mail" do
  end
  
  it "should send scheduled mail" do
  end

  it "should accept arguments" do
  end
end