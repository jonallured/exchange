module UrlHelper
  def artsy_view_artwork_url(artwork_id)
    artwork_url = Rails.application.config_for(:force)['artwork_url']
    "#{artwork_url}/#{artwork_id}"
  end

  def artsy_view_user_admin_url(user_id)
    user_url = Rails.application.config_for(:torque)['user_url']
    "#{user_url}/#{user_id}"
  end

  def artsy_view_partner_admin_url(partner_id)
    partners_url = Rails.application.config_for(:vibrations)['partners_url']
    "#{partners_url}/#{partner_id}"
  end

  def artsy_view_conversation_url(impulse_conversation_id)
    impulse_conversations_url = Rails.application.config_for(:impulse)['admin_conversations_url']
    "#{impulse_conversations_url}/#{impulse_conversation_id}"
  end
end
