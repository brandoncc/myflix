class SignUpService
  attr_reader :status, :message
  def initialize(user)
    @user = user
  end

  def register(options = {})
    if @user.valid?
      subscription = StripeWrapper::Subscription.subscribe(@user, options[:stripe_token])
      if subscription.successful?
        @user.save
        handle_invite(options[:invitation_token])
        AppMailer.delay.welcome_email(@user)
        @status = :success
        @message = 'Account created successfully, you have been logged in.'
        self
      else
        @status = :failure
        @message = subscription.error_message
        self
      end
    else
      @status = :failure
      @message = 'There was a problem creating your account. Please try again.'
      self
    end
  end

  def successful?
    status == :success
  end

  private

  def handle_invite(token)
    @invite = Invite.find_by(token: token)
    follow_and_lead_inviter(@user)
    expire_invite_token
  end

  def follow_and_lead_inviter(new_user)
    if @invite && @invite.creator
      @invite.creator.follow(new_user)
      new_user.follow(@invite.creator)
    end
  end

  def expire_invite_token
    @invite.update_column(:token, nil) if @invite && !@invite.new_record?
  end
end
