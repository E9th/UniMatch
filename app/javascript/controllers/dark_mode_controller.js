import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dark-mode"
export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyTheme()
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    if (isDark) {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("darkMode", "false")
    } else {
      document.documentElement.classList.add("dark")
      localStorage.setItem("darkMode", "true")
    }
    this.updateIcons()
  }

  applyTheme() {
    const saved = localStorage.getItem("darkMode")
    if (saved === "true" || (!saved && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
    this.updateIcons()
  }

  updateIcons() {
    const isDark = document.documentElement.classList.contains("dark")
    this.iconTargets.forEach(icon => {
      icon.className = isDark
        ? "fa-solid fa-sun text-amber-400"
        : "fa-solid fa-moon"
    })
  }
}
