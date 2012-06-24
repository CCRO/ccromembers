require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "Only authorized users can read posts" do
    user_basic = Person.find_by_email('basic@ccro.org')
    user_pro = Person.find_by_email('pro@ccro.org')
    user_committee = Person.find_by_email('committee@ccro.org')
    user_editor = Person.find_by_email('editor@ccro.org')
    ability = Ability.new(user_basic)
    assert ability.can?(:read, Post.new(level: 'basic', published: true)), "Basic user cannot read basic Post"
    assert ability.cannot?(:read, Post.new(level: 'pro', published: true)), "Basic user can read pro Post"
    assert ability.cannot?(:read, Post.new(level: 'committee', published: true)), "Basic user can read committee Post"
    assert ability.cannot?(:read, Post.new(published: false)), "Basic user can read draft Post"
    ability = Ability.new(user_pro)
    assert ability.can?(:read, Post.new(level: 'basic', published: true)), "Pro user cannot read basic Post"
    assert ability.can?(:read, Post.new(level: 'pro', published: true)), "Pro user cannot read pro Post"
    assert ability.cannot?(:read, Post.new(level: 'committee', published: true)), "Pro user can read committee Post"
    assert ability.cannot?(:read, Post.new(published: false)), "Pro user can read draft Post"
    ability = Ability.new(user_committee)
    assert ability.can?(:read, Post.new(level: 'basic', published: true)), "Committee user cannot read basic Post"
    assert ability.can?(:read, Post.new(level: 'pro', published: true)), "Committee user cannot read pro Post"
    assert ability.can?(:read, Post.new(level: 'committee', published: true)), "Committee user cannot read committee Post"
    assert ability.cannot?(:read, Post.new(published: false)), "Committee user can read draft Post"
    ability = Ability.new(user_editor)
    assert ability.can?(:read, Post.new(level: 'basic', published: true)), "Editor user cannot read basic Post"
    assert ability.can?(:read, Post.new(level: 'pro', published: true)), "Editor user cannot read pro Post"
    assert ability.can?(:read, Post.new(level: 'committee', published: true)), "Editor user cannot read committee Post"
    assert ability.can?(:read, Post.new(published: false)), "Editor user cannot read draft Post"
    
  end

  test "Only editors and admins can create Post" do
    user_basic = Person.find_by_email('basic@ccro.org')
    user_editor = Person.find_by_email('editor@ccro.org')
    user_admin = Person.find_by_email('admin@ccro.org')
    ability = Ability.new(user_editor)
    assert ability.can?(:create, Post), "Editor cannot create Post"
    ability = Ability.new(user_admin)
    assert ability.can?(:create, Post), "Admin cannot create Post"
    ability = Ability.new(user_basic)
    assert ability.cannot?(:create, Post), "Basic users can create Post"
  end

  test "user can only destroy posts which he authored" do
    user = Person.find_by_email('basic@ccro.org')
    ability = Ability.new(user)
    assert ability.can?(:destroy, Post.new(:author => user)), "Cannot destory Post that I own"
    assert ability.cannot?(:destroy, Post.new), "Can destroy Post that I do not own"
  end
  
  
end
