import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = {
    url: String
  }

  initialize() {
    this.scroll = this.scroll.bind(this)
    this.loading = false
  }

  connect() {
    this.createObserver()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  createObserver() {
    const options = {
      root: null,
      rootMargin: "200px",
      threshold: 0.1
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadMore()
        }
      })
    }, options)

    if (this.hasPaginationTarget) {
      this.observer.observe(this.paginationTarget)
    }
  }

  async loadMore() {
    if (this.loading) return

    const nextPageUrl = this.nextPageUrl()
    if (!nextPageUrl) {
      this.observer?.disconnect()
      return
    }

    this.loading = true

    try {
      const response = await fetch(nextPageUrl, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error loading more items:", error)
    } finally {
      this.loading = false
    }
  }

  nextPageUrl() {
    if (!this.hasPaginationTarget) return null

    const nextLink = this.paginationTarget.querySelector('a[rel="next"]')
    return nextLink ? nextLink.href : null
  }
}
