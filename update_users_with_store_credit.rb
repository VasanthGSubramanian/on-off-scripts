# frozen_string_literal: true

user_emails_country = %w[vasanth.subramanian@glossier.com:US]
actor_email = 'vasanth.subramanian@glossier.com'
# memo = ''
actor = Spree::User.find_by(email: actor_email)
reason = 'retroactive_promotion_technical_issue',
         country_currency_hash = { 'US' => 'USD', 'SE' => 'SEK', 'GB' => 'GBP', 'CA' => 'CAD', 'IE' => 'EUR' }
amount_to_credit_hash = { 'USD' => 5, 'SEK' => 50, 'GB' => 5, 'CAD' => 5, 'IE' => 5 }
credit_category_name = 'Customer Service'
credit_category = ::Spree::StoreCreditCategory.find_by!(name: credit_category_name)

results = []
user_emails.each do |obj|
  obj_array = obj.split(':')
  email = obj_array[0]
  country = obj_array[1]
  user = Spree::User.find_by(email: email)
  currency = country_currency_hash[country]
  amount = amount_to_credit_hash[currency]
  if user.nil?
    results << [:user_not_found, email]
    next
  end

  begin
    Glossier::Concessions::CreateStoreCredit.call(
      issuer: actor,
      recipient: user,
      reason: reason,
      credit_category: credit_category,
      amount: amount,
      currency: currency
    )
    results << [:ok, email, actor, user, reason, credit_category, amount, currency]
  rescue StandardError => e
    results << [e.message, email]
  end
end
