class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Person.new # guest user (not logged in)
    
    can :read, Post
    
    if user.member?
      can :read, [Document, Comment, Message]
    end
    
    if user.role == 'editor'
      can :create, [Post, Document, Message]
      can :manage, Post
    end
    
    can :create, Comment
    
    if user.primary_contact? || user.billing_contact?
      can :edit, Person, :company_id => user.company_id
      can :manage, Company, :id => user.company_id
      cannot :destroy, Company
    end
    
    can :read, Company, :id => user.company_id

    can :edit, [Post, Document, Comment, Message], :author_id => user.id
    
    can :manage, Person, :id => user.id
    can :read, Company, :id => user.company.id
    
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
