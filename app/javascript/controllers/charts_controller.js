import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  connect() {
    this.weekOffset = 0
    this.initChart()
    this.loadWeek(this.weekOffset)
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  initChart() {
    const existingChart = Chart.getChart(this.canvasTarget)
    if (existingChart) {
      existingChart.destroy()
    }

    const ctx = this.canvasTarget.getContext("2d")
    this.chart = new Chart(ctx, {
      type: 'bar',
      data: { labels: [], datasets: [{ data: [] }] },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          title: { display: true, text: "" },
          legend: { display: false }
        }
      }
    })
  }

  loadWeek(offset) {
    fetch(`/home.json?week_offset=${offset}`)
      .then(res => res.json())
      .then(data => {
        const labels = data.map(d => d.label)
        const fullLabels = data.map(d => d.full_label)
        const counts = data.map(d => d.count)

        this.chart.data.labels = labels
        this.chart.data.datasets[0].data = counts
        this.chart.options.plugins.title.text = `${fullLabels[0]} ~ ${fullLabels[6]}`
        this.chart.update()
      })
  }

  prevWeek() {
    this.weekOffset--
    this.loadWeek(this.weekOffset)
  }

  nextWeek() {
    this.weekOffset++
    this.loadWeek(this.weekOffset)
  }
}