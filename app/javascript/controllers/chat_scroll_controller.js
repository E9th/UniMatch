import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-scroll"
export default class extends Controller {
  static targets = ["container", "messages"]

  connect() {
    this.scrollToBottom()
    if (this.hasMessagesTarget) {
      this.observer = new MutationObserver(() => this.scrollToBottom())
      this.observer.observe(this.messagesTarget, { childList: true })
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    if (this.hasContainerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight
    }
  }
}
