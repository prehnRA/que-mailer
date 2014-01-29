require 'spec_helper'

# Set up a dummy logger.
Que.logger = $logger = Object.new
$logger_mutex = Mutex.new # Protect against rare errors on Rubinius/JRuby.

def $logger.messages
  @messages ||= []
end

def $logger.method_missing(m, message)
  $logger_mutex.synchronize { messages << message }
end

# Helper for testing threaded code.
QUE_TEST_TIMEOUT ||= 2
def sleep_until(timeout = QUE_TEST_TIMEOUT)
  deadline = Time.now + timeout
  loop do
    break if yield
    raise "Thing never happened!" if Time.now > deadline
    sleep 0.01
  end
end

describe Que::Mailer do
  it "should send mail" do
    QueJob.delete_all
    ActionMailer::Base.deliveries = []
    QueJob.count.should be 0
    
    ActionMailer::Base.deliveries.length.should be 0
    TestMailer.test_message.deliver
    QueJob.count.should be 1
    
    TestMailer::MailJob.work
    
    Que::Worker.workers.each do |worker|
      worker.wake!
    end
    sleep_until { Que::Worker.workers.all?(&:sleeping?) }
    QueJob.count.should be 0
    ActionMailer::Base.deliveries.length.should be 1
    QueJob.count.should be 0
  end
  
  it "should send delayed mail" do
    QueJob.delete_all
    ActionMailer::Base.deliveries = []
    QueJob.count.should be 0
    
    ActionMailer::Base.deliveries.length.should be 0
    TestMailer.test_message.deliver_in(60)
    QueJob.count.should be 1
    ActionMailer::Base.deliveries.length.should be 0
    QueJob.first.run_at.should be_within(3).of Time.now + 60
    QueJob.delete_all
  end
  
  it "should send scheduled mail" do
    QueJob.delete_all
    ActionMailer::Base.deliveries = []
    QueJob.count.should be 0
    
    ActionMailer::Base.deliveries.length.should be 0
    TestMailer.test_message.deliver_at(Time.now+60)
    QueJob.count.should be 1
    ActionMailer::Base.deliveries.length.should be 0
    QueJob.first.run_at.should be_within(3).of Time.now + 60
    QueJob.delete_all
  end

  it "should work in async mode" do
    Rails.application.config.mode = :async
    QueJob.delete_all
    ActionMailer::Base.deliveries = []
    QueJob.count.should be 0
    ActionMailer::Base.deliveries.length.should be 0
    
    TestMailer.test_message.deliver
    QueJob.count.should be 1
    
    #Wake all the workers up, then wait until they all sleep
    Que::Worker.workers.each do |worker|
      worker.wake!
    end
    sleep_until { Que::Worker.workers.all?(&:sleeping?) }
    
    QueJob.count.should be 0
    
    ActionMailer::Base.deliveries.length.should be 1
    Rails.application.config.mode = :sync
  end

  it "should accept arguments" do
    QueJob.delete_all
    ActionMailer::Base.deliveries = []
    QueJob.count.should be 0
    
    secret1 = (0..10).map {|x| ('a'..'z').to_a[rand(26)]}.join
    secret2 = (0..10).map {|x| ('a'..'z').to_a[rand(26)]}.join
    
    ActionMailer::Base.deliveries.length.should be 0
    TestMailer.test_message({:arg1=>secret1, :arg2=>secret2}).deliver
    QueJob.count.should be 1
    
    TestMailer::MailJob.work
    
    Que::Worker.workers.each do |worker|
      worker.wake!
    end
    sleep_until { Que::Worker.workers.all?(&:sleeping?) }
    QueJob.count.should be 0
    ActionMailer::Base.deliveries.length.should be 1
    ActionMailer::Base.deliveries[0].text_part.body.should include(secret1)
    ActionMailer::Base.deliveries[0].text_part.body.should include(secret2)
    QueJob.count.should be 0
  end
end