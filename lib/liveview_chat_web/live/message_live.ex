defmodule LiveviewChatWeb.MessageLive do
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message
  # run authentication on mount
  on_mount LiveviewChatWeb.AuthController

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    # add name parameter if loggedin
    changeset =
      if socket.assigns.loggedin do
        Message.changeset(%Message{}, %{"name" => socket.assigns.person["givenName"]})
      else
        Message.changeset(%Message{}, %{})
      end

    messages = Message.list_messages() |> Enum.reverse()

    {:ok, assign(socket, messages: messages, changeset: changeset),
     temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    LiveviewChatWeb.MessageView.render("messages.html", assigns)
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      :ok -> # broadcast returns :ok (just the atom!) if there are no errors
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
      end
  end

  def handle_info({:message_created, message}, socket) do
#    messages = socket.assigns.messages ++ [message] # append new message to the existing list
    {:noreply, assign(socket, messages: [message])}
  end
end
