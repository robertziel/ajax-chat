class ChatController < ApplicationController
  def index
    @users = User.where.not(id: current_user.id).all
  end

  def begin_conversation
    if Conversation.between(current_user.id, params[:recipient_id]).present?
      @conversation = Conversation.between(current_user.id,
                                           params[:recipient_id]).first
    else
      @conversation = Conversation.create!(sender_id: current_user.id,
                                           recipient_id: params[:recipient_id])
    end
    @message = Message.new
    chat_box = render_to_string(template: 'chat/chat_box', layout: false)
    render json: { conversation_id: @conversation.id, chat_box: chat_box }
  end

  def create_message
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user_id = current_user.id
    if @message.save
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
