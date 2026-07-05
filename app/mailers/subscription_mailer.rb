class SubscriptionMailer < ApplicationMailer
  default from: "billing@careerai.com"
  layout "mailer"

  def activated
    @user = params[:user]
    @billing_history = params[:billing_history]

    mail(
      to: @user.email,
      subject: "Welcome to CareerAI Premium! 🎉"
    )
  end

  def renewed
    @user = params[:user]
    @billing_history = params[:billing_history]

    mail(
      to: @user.email,
      subject: "Your CareerAI Subscription Renewed"
    )
  end

  def payment_failed
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Action Required: CareerAI Payment Failed"
    )
  end

  def expired
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Your CareerAI Subscription has Expired"
    )
  end

  def credit_reset
    @user = params[:user]

    mail(
      to: @user.email,
      subject: "Your Monthly AI Credits have been Reset! ✨"
    )
  end
end
