class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  validates :content, :conversation_id, :user_id, presence: true

  before_save :message_belongs_to_user_belonging_to_conversation

  def message_belongs_to_user_belonging_to_conversation
    return true if conversation.sender_id == user_id
    return true if conversation.recipient_id == user_id
    return false
  end
end
