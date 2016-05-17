class ChatController
  opened_conversations = []

  constructor: (chat_opener, chat_boxes_container) ->
    $(chat_opener).click ->
      $.ajax
        type: 'POST'
        url: $(this).data('begin-conversation')
        dataType: 'json'
        beforeSend: (xhr) ->
          xhr.setRequestHeader 'X-CSRF-Token',
                               $('meta[name="csrf-token"]').attr('content')
        data:
          recipient_id: $(this).data('recipient-id')
        success: (data) ->
          index = opened_conversations.indexOf(data['conversation_id'])
          if index > -1
            opened_conversations.splice(index, 1)
            close_conversation_box(data['conversation_id'])
          else
            opened_conversations.push(data['conversation_id'])
            open_conversation_box(data['conversation_id'],
                                  data['chat_box'],
                                  chat_boxes_container)

  open_conversation_box = (conversation_id, chat_box, chat_boxes_container) ->
    $(chat_box).appendTo($(chat_boxes_container))
    send_listener()
    new_messages_listener(conversation_id)
    scroll_down(get_chatbox(conversation_id).children('.messages-container'))

  close_conversation_box = (conversation_id) ->
    get_chatbox(conversation_id).remove()

  send_listener = () ->
    $('.chat-boxes-container').unbind().on 'keyup', 'textarea', (e) ->
      code = (if e.keyCode then e.keyCode else e.which)
      if code is 13
        send_message($(this).parent())
      return true

  send_message = (form) ->
    $.ajax
      type: 'POST'
      url: form.attr('action')
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'X-CSRF-Token',
          $('meta[name="csrf-token"]').attr('content')
      data: form.serialize()
      success: (data) ->
        if data['success']
          form.children('#message_content').val('')

  new_messages_listener = (conversation_id) ->
    if opened_conversations.indexOf(conversation_id) != -1
      ask_for_new_message(conversation_id)
      setTimeout (->
        new_messages_listener(conversation_id)
      ), 500

  ask_for_new_message = (conversation_id) ->
    chat = get_chatbox(conversation_id)
    $.ajax
      type: 'GET'
      url: chat.data('url')
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'X-CSRF-Token',
          $('meta[name="csrf-token"]').attr('content')
      data: { newest_message_id: chat.data('newest-message-id') }
      success: (data) ->
        if data['success']
          chat.data('newest-message-id', data['message']['id'])
          messages_container = chat.children('.messages-container')
          append_new_message(messages_container, data['message'])
          scroll_down(messages_container)

  append_new_message = (messages_container, message) ->
    new_message_html = $(messages_container.data('message-pattern'))
    new_message_html.children('.message-content').text(message['content'])
    if message['user_id'] == messages_container.data('your-id')
      new_message_html.addClass('your-message')
    messages_container.append(new_message_html)

  scroll_down = (messages_container) ->
    messages_container.scrollTop(messages_container[0].scrollHeight)

  get_chatbox = (conversation_id) ->
    return $('.chat-container[data-conversation-id="' + conversation_id + '"]')

$ ->
  new ChatController('.open-chat-box',
                     '.chat-boxes-container')
