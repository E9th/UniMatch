import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["preview", "img", "fileInput"]

  preview(event) {
    const file = event.target.files[0]
    if (!file) return

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert("ไฟล์ใหญ่เกินไป (สูงสุด 5MB)")
      event.target.value = ""
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasImgTarget && this.hasPreviewTarget) {
        this.imgTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
      }
    }
    reader.readAsDataURL(file)
  }

  remove() {
    if (this.hasPreviewTarget) {
      this.previewTarget.classList.add("hidden")
    }
    if (this.hasImgTarget) {
      this.imgTarget.src = ""
    }
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
  }
}
