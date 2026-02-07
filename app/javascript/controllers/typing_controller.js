import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="typing"
export default class extends Controller {
  static values = { roomId: Number, userId: Number }
  static targets = ["indicator"]

  connect() {
    this.typing = false
    this.typingTimeout = null

    this.channel = createConsumer().subscriptions.create(
      { channel: "TypingChannel", chat_room_id: this.roomIdValue },
      {
        received: (data) => this.handleReceived(data)
      }
    )
  }

  disconnect() {
    if (this.channel) this.channel.unsubscribe()
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
  }

  // Called on input event from textarea
  input() {
    if (!this.typing) {
      this.typing = true
      this.channel.perform("typing", { typing: true })
    }

    // Reset the timeout
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
    this.typingTimeout = setTimeout(() => {
      this.typing = false
      this.channel.perform("typing", { typing: false })
    }, 2000)
  }

  // Called on form submit — stop typing
  stop() {
    this.typing = false
    if (this.typingTimeout) clearTimeout(this.typingTimeout)
    this.channel.perform("typing", { typing: false })
  }

  handleReceived(data) {
    // Don't show my own typing
    if (data.user_id === this.userIdValue) return

    if (this.hasIndicatorTarget) {
      this.indicatorTarget.style.display = data.typing ? "flex" : "none"
    }
  }
}
