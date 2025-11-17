import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["widget", "messages", "input", "greeting"]

  connect() {
    this.closed = true
    this.loadMessages()
  }

  toggle() {
    this.closed = !this.closed
    const widget = this.widgetTarget

    if (this.closed) {
      widget.classList.add("hidden")
    } else {
      widget.classList.remove("hidden")
      this.scrollToBottom()
      // Focus input when opening
      if (this.hasInputTarget) {
        this.inputTarget.focus()
      }
    }
  }

  async loadMessages() {
    try {
      const response = await fetch('/account/support_messages.json')
      if (response.ok) {
        const data = await response.json()
        this.renderMessages(data.messages)
      }
    } catch (error) {
      console.error('Failed to load messages:', error)
    }
  }

  renderMessages(messages) {
    if (!this.hasMessagesTarget) return

    // Clear existing messages
    this.messagesTarget.innerHTML = ''

    // Show greeting if no messages
    if (messages.length === 0 && this.hasGreetingTarget) {
      this.greetingTarget.classList.remove('hidden')
    } else if (this.hasGreetingTarget) {
      this.greetingTarget.classList.add('hidden')
    }

    // Render each message
    messages.forEach(message => {
      const messageEl = this.createMessageElement(message)
      this.messagesTarget.appendChild(messageEl)
    })

    this.scrollToBottom()
  }

  createMessageElement(message) {
    const div = document.createElement('div')
    div.className = `mb-4 ${message.from_admin ? 'text-left' : 'text-right'}`

    const bubble = document.createElement('div')
    bubble.className = `inline-block max-w-[80%] px-4 py-2 rounded-lg ${
      message.from_admin
        ? 'bg-gray-200 text-gray-900'
        : 'bg-purple-600 text-white'
    }`

    const text = document.createElement('p')
    text.className = 'text-sm whitespace-pre-wrap'
    text.textContent = message.message

    const time = document.createElement('p')
    time.className = 'text-xs mt-1 opacity-70'
    time.textContent = this.formatTime(message.created_at)

    bubble.appendChild(text)
    bubble.appendChild(time)
    div.appendChild(bubble)

    return div
  }

  formatTime(timestamp) {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now - date
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    if (minutes < 1) return 'Just now'
    if (minutes < 60) return `${minutes}m ago`
    if (hours < 24) return `${hours}h ago`
    if (days < 7) return `${days}d ago`
    return date.toLocaleDateString()
  }

  async sendMessage(event) {
    event.preventDefault()

    if (!this.hasInputTarget) return

    const message = this.inputTarget.value.trim()
    if (!message) return

    // Disable input while sending
    this.inputTarget.disabled = true

    try {
      const response = await fetch('/account/support_messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          support_message: {
            message: message
          }
        })
      })

      if (response.ok) {
        this.inputTarget.value = ''
        await this.loadMessages()
      } else {
        alert('Failed to send message. Please try again.')
      }
    } catch (error) {
      console.error('Failed to send message:', error)
      alert('Failed to send message. Please try again.')
    } finally {
      this.inputTarget.disabled = false
      this.inputTarget.focus()
    }
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }
}
