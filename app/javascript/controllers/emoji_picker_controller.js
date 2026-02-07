import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="emoji-picker"
export default class extends Controller {
  static targets = ["menu", "input"]

  // Common emoji set grouped by category
  emojis = [
    "😀", "😂", "🤣", "😊", "😍", "🥰", "😎", "🤓",
    "😅", "😆", "😉", "😋", "😘", "🤗", "🤔", "🤫",
    "😱", "😭", "😤", "🥺", "😴", "🤯", "🥳", "😇",
    "👍", "👎", "👏", "🙏", "💪", "✌️", "🤝", "👋",
    "❤️", "🔥", "⭐", "💯", "✅", "❌", "💡", "📚",
    "✍️", "📝", "🎓", "🧠", "💻", "📖", "🏆", "🎉"
  ]

  connect() {
    // Close picker when clicking outside
    this.outsideClickHandler = (e) => {
      if (!this.element.contains(e.target)) this.close()
    }
    document.addEventListener("click", this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClickHandler)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("hidden")
    }
  }

  close() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
    }
  }

  select(event) {
    event.preventDefault()
    const emoji = event.currentTarget.dataset.emoji
    if (this.hasInputTarget) {
      const textarea = this.inputTarget
      const start = textarea.selectionStart
      const end = textarea.selectionEnd
      const text = textarea.value
      textarea.value = text.substring(0, start) + emoji + text.substring(end)
      textarea.selectionStart = textarea.selectionEnd = start + emoji.length
      textarea.focus()
    }
    this.close()
  }
}
