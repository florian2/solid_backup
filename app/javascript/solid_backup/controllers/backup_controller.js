import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "log"]
  
  connect() {
    console.log("Backup controller connected")
  }
  
  run(event) {
    event.preventDefault()
    
    if (!confirm("Are you sure you want to run this backup now?")) {
      return
    }
    
    const url = event.currentTarget.getAttribute("href")
    
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
  }
  
  toggleLog(event) {
    event.preventDefault()
    this.logTarget.classList.toggle("d-none")
  }
}