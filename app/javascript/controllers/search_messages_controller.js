import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-messages"
export default class extends Controller {
  static targets = ["input", "results", "toggle", "bar"]

  connect() {
    this.visible = false
  }

  toggleSearch() {
    this.visible = !this.visible
    if (this.hasBarTarget) {
      this.barTarget.style.display = this.visible ? "flex" : "none"
    }
    if (this.visible && this.hasInputTarget) {
      this.inputTarget.focus()
      this.inputTarget.value = ""
      this.clearHighlights()
    }
  }

  search() {
    const query = this.hasInputTarget ? this.inputTarget.value.trim().toLowerCase() : ""
    this.clearHighlights()

    if (query.length < 1) {
      if (this.hasResultsTarget) this.resultsTarget.textContent = ""
      return
    }

    const messages = document.querySelectorAll("#messages > div")
    let count = 0
    let firstMatch = null

    messages.forEach(msg => {
      const bubble = msg.querySelector(".msg-enter")
      if (!bubble) return
      const text = bubble.textContent.toLowerCase()
      if (text.includes(query)) {
        count++
        msg.style.opacity = "1"
        // Highlight matching text
        this.highlightText(bubble, query)
        if (!firstMatch) firstMatch = msg
      } else {
        msg.style.opacity = "0.3"
      }
    })

    if (this.hasResultsTarget) {
      this.resultsTarget.textContent = count > 0 ? `พบ ${count} ข้อความ` : "ไม่พบ"
    }

    // Scroll to first match
    if (firstMatch) {
      firstMatch.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }

  highlightText(element, query) {
    const walker = document.createTreeWalker(element, NodeFilter.SHOW_TEXT)
    const nodes = []
    while (walker.nextNode()) nodes.push(walker.currentNode)

    nodes.forEach(node => {
      const idx = node.textContent.toLowerCase().indexOf(query)
      if (idx === -1) return
      const range = document.createRange()
      range.setStart(node, idx)
      range.setEnd(node, idx + query.length)
      const mark = document.createElement("mark")
      mark.className = "bg-yellow-300 dark:bg-yellow-500 rounded px-0.5"
      range.surroundContents(mark)
    })
  }

  clearHighlights() {
    // Remove all <mark> elements
    document.querySelectorAll("#messages mark").forEach(mark => {
      const parent = mark.parentNode
      parent.replaceChild(document.createTextNode(mark.textContent), mark)
      parent.normalize()
    })
    // Reset opacity
    document.querySelectorAll("#messages > div").forEach(msg => {
      msg.style.opacity = "1"
    })
  }

  close() {
    this.visible = false
    if (this.hasBarTarget) this.barTarget.style.display = "none"
    if (this.hasInputTarget) this.inputTarget.value = ""
    this.clearHighlights()
  }
}
