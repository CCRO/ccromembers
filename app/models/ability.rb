class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Person.new # guest user (not logged in)
        
    can :read, [Post, Page], {level: 'public', published: true}
    can :create, Person
    can :read, Person
    can :read, Billboard
    cannot :manage, Subscription
   
    if false
      can :read, Group do |group|
          group.people.include? user
      end
    else
      can :read, Group
    end

    can :read, Attachment, level: 'public'

    can :read, [Document, Message, Page, Post] do |object|
      if object.owner.class.name == "Group" 
        object.owner.people.include?(user)
      else
        false
      end
    end

    can [:read, :comment_on, :download], Attachment do |object|
      if object.owner.present? && object.owner_type == 'Group'
        object.owner.people.include? user
      else
        false
      end
    end



    can [:edit, :destroy, :publish], [Post, Document, Message, Page] do |object|
      object.owner_type == "Group" && (object.owner.memberships.where(:fuction => 'chair').map { |membership| membership.person }.include?(user) || object.owner.memberships.where(:fuction => 'coordinator').map { |membership| membership.person }.include?(user))
    end
    
    can :create_in, Group do |group|
      (group.memberships.where(:fuction => 'chair').map { |membership| membership.person }.include?(user) || group.memberships.where(:fuction => 'coordinator').map { |membership| membership.person }.include?(user))
    end

    can :comment_on, Message do |object|
      if object.owner.present? && object.owner_type == 'Group'
        object.owner.people.include? user
      else
        user.basic?
      end
    end
    
    if user.basic?
      can :read, [PollingSession, Poll]
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, [Post, Page, Document], {level: 'basic', published: true}
      can :create, Comment
      can [:edit, :destroy], [Post, Document, Comment, Message, Page], :author_id => user.id
      can :edit, Person, :id => user.id
      can :read, Attachment, {level: 'basic'}
      can :comment_on, Attachment, {comment_level: 'basic'}
      can :download, Attachment, {download_level: 'basic'}
    end
    
    if user.pro?
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, [Post, Page, Document], {level: 'pro', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, Survey, {level: 'pro', :active => true}
      can :read, Attachment, {level: ['basic', 'pro']}  
      can :comment_on, Attachment, {comment_level: ['basic', 'pro']}  
      can :download, Attachment, {download_level: ['basic', 'pro']}  
    end

    if user.subscriber?
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, [Post, Page, Document], {level: 'pro', :published => true}
      can :read, [Post, Page, Document], {level: 'subscriber', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, Survey, {level: 'pro', :active => true}
      can :read, Survey, {level: 'subscriber', :active => true}
      can :read, Attachment, {level: ['basic', 'pro', 'subscriber']}  
      can :comment_on, Attachment, {comment_level: ['basic', 'pro', 'subscriber']}  
      can :download, Attachment, {download_level: ['basic', 'pro', 'subscriber']}  
    end
    
    if user.individual_member?
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, [Post, Page, Document], {level: 'pro', :published => true}
      can :read, [Post, Page, Document], {level: 'subscriber', :published => true}  
      can :read, [Post, Page, Document], {level: 'individual_member', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, Survey, {level: 'pro', :active => true}
      can :read, Survey, {level: 'subscriber', :active => true}
      can :read, Survey, {level: 'individual_member', :active => true}  
      can :read, Attachment, {level: ['basic', 'pro', 'subscriber', 'individual_member']}
      can :comment_on, Attachment, {comment_level: ['basic', 'pro', 'subscriber', 'individual_member']}
      can :download, Attachment, {download_level: ['basic', 'pro', 'subscriber', 'individual_member']}
      can :read, [Group, Message, Comment, Survey]
      can :read, Company, :id => user.company_id
      
      if user.primary_contact? || user.billing_contact?
        can :edit, Person, :company_id => user.company_id
        can :manage, Company, :id => user.company_id
        cannot :destroy, Company
      end
    end

    if user.company_member?
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, [Post, Page, Document], {level: 'pro', :published => true}
      can :read, [Post, Page, Document], {level: 'subscriber', :published => true}  
      can :read, [Post, Page, Document], {level: 'individual_member', :published => true}
      can :read, [Post, Page, Document], {level: 'company_member', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, Survey, {level: 'pro', :active => true}
      can :read, Survey, {level: 'subscriber', :active => true}
      can :read, Survey, {level: 'individual_member', :active => true}
      can :read, Survey, {level: 'company_member', :active => true}  
      can :read, Attachment, {level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member']}
      can :comment_on, Attachment, {comment_level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member']}
      can :download, Attachment, {download_level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member']}
      can :read, [Group, Message, Comment]
      can :read, Company, :id => user.company_id
      
      if user.primary_contact? || user.billing_contact?
        can :edit, Person, :company_id => user.company_id
        can :manage, Company, :id => user.company_id
        cannot :destroy, Company
      end
    end

    if user.leadership?
      can :read, [Post, Page, Document], {level: 'basic', :published => true}
      can :read, [Post, Page, Document], {level: 'pro', :published => true}  
      can :read, [Post, Page, Document], {level: 'subscriber', :published => true}
      can :read, [Post, Page, Document], {level: 'individual_member', :published => true}  
      can :read, [Post, Page, Document], {level: 'company_member', :published => true}
      can :read, [Post, Page, Document], {level: 'leadership', :published => true}
      can :read, Survey, {level: 'basic', :active => true}
      can :read, Survey, {level: 'pro', :active => true}
      can :read, Survey, {level: 'subscriber', :active => true}
      can :read, Survey, {level: 'individual_member', :active => true}
      can :read, Survey, {level: 'company_member', :active => true}
      can :read, Survey, {level: 'leadership', :active => true}
      can :read, Attachment, {level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member', 'leadership']}   
      can :comment_on, Attachment, {comment_level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member', 'leadership']}   
      can :download, Attachment, {download_level: ['basic', 'pro', 'subscriber', 'individual_member', 'company_member', 'leadership']}   
      can :read, [Group, Message, Comment]
      can :read, Company, :id => user.company_id
      
      if user.primary_contact? || user.billing_contact?
        can :edit, Person, :company_id => user.company_id
        can :manage, Company, :id => user.company_id
        cannot :destroy, Company
      end
    end
    
    if user.editor?
      can :read, [Post, Page], {level: 'basic', :published => true}
      can :read, [Post, Page], {level: 'pro', :published => true}  
      can :read, [Post, Page], {level: 'subscriber', :published => true}
      can :read, [Post, Page], {level: 'individual_member', :published => true}
      can :read, [Post, Page], {level: 'company_member', :published => true}  
      can :read, [Post, Page], {level: 'leadership', :published => true}    
      can :read, [Post, Page], :published => false
      can :create, [Post, Page]
      can [:edit,:destroy], [Post, Page]
      cannot :publish, [Post, Page]
    end

    can [:read], Survey do |object|
      if object.owner.present? && object.owner_type == 'Group'
        object.owner.people.include? user
      else
        false
      end
    end
            
    can :manage, :all if user.admin?
    
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
