class TestMailer < ActionMailer::Base
  include Que::Mailer
  default from: 'from@example.com'
      
  def test_message
    mail(to: "joe@example.com", subject: "A Test Message")
  end
end