class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Person.new # guest user (not logged in)
        
    can :read, Post, {level: 'public', published: true}
    can :create, Person
    can :read, Survey if user.id
    
    if user.basic?
      can :read, [PollingSession, Poll]
      can :read, Survey if user.id
      can :read, Post, {level: 'basic', published: true}
      can :create, Comment
      can [:edit, :destroy], [Post, Document, Comment, Message], :author_id => user.id
      can :manage, Person, :id => user.id
      
    end
    
    if user.pro?
      can :read, Post, {level: 'basic', :published => true}
      can :read, Post, {level: 'pro', :published => true}  
    end
    
    if user.committee?
      can :read, Post, {level: 'basic', :published => true}
      can :read, Post, {level: 'pro', :published => true}  
      can :read, Post, {level: 'committee', :published => true}  
      can :read, [Document, Comment, Message, Survey]
      can :read, Post, :published => true
      can :read, Company, :id => user.company_id
      
      if user.primary_contact? || user.billing_contact?
        can :edit, Person, :company_id => user.company_id
        can :manage, Company, :id => user.company_id
        cannot :destroy, Company
      end
    end
    
    if user.editor?
      can :read, Post, {level: 'basic', :published => true}
      can :read, Post, {level: 'pro', :published => true}  
      can :read, Post, {level: 'committee', :published => true}  
      can :read, Post, :published => false
      can :create, [Post, Document, Message, Survey]
      can [:edit,:destroy], Post
      cannot :publish, Post
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
