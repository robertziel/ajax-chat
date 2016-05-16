Rails.application.routes.draw do

  root 'chat#index'
  post '/begin_conversation' => 'chat#begin_conversation'
  post '/conversation/:conversation_id/new_message' => 'chat#create_message', as: :conversation_messages
  get '/conversation/:conversation_id/take_message' => 'chat#take_new_message', as: :take_conversation_messages

  devise_for :users

end
