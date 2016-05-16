module ChatHelper
  def newest_message_id(messages)
    return 0 if messages.empty?
    messages.pluck(:id).max
  end
end
