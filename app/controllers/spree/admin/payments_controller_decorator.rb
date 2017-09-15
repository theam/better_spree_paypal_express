Spree::Admin::PaymentsController.class_eval do
  def paypal_refund
    if request.get?
      if @payment.source.state == 'refunded'
        flash[:error] = Spree.t(:already_refunded, :scope => 'paypal')
        redirect_to admin_order_payment_path(@order, @payment)
      end
    elsif request.post?
      credit_cents = Spree::Money.new(params[:refund_amount].to_f, currency: @payment.currency).money.cents
      response = @payment.payment_method.refund(@payment, credit_cents)
      if response.success?
        flash[:success] = Spree.t(:refund_successful, :scope => 'paypal')
        redirect_to admin_order_payments_path(@order)
      else
        flash.now[:error] = Spree.t(:refund_unsuccessful, :scope => 'paypal') + " (#{response.errors.first.long_message})"
        render
      end
    end
  end
end