import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="online-status"
// Pings the server every 30s to update last_seen_at
export default class extends Controller {
  connect() {
    this.ping() // immediate first ping
    this.interval = setInterval(() => this.ping(), 30000) // every 30s
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  async ping() {
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      await fetch("/ping", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json"
        }
      })
    } catch (e) {
      // silently fail
    }
  }
}
