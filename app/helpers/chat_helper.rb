module ChatHelper
  def newest_message_id(messages)
    return 0 if messages.empty?
    messages.pluck(:id).max
  end

  def your_message_class(message)
    return '' if message.nil?
    message.user == current_user ? 'your-message' : ''
  end
end
