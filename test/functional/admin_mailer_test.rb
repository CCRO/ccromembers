require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  test "signup_complete" do
    mail = AdminMailer.signup_complete
    assert_equal "Signup complete", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
