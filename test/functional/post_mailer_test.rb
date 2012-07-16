require 'test_helper'

class PostMailerTest < ActionMailer::TestCase
  test "share_post" do
    mail = PostMailer.share_post
    assert_equal "Share post", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
