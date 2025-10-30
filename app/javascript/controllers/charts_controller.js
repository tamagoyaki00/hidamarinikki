import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "weekTab", "monthTab", "prevButton", "nextButton"]

  connect() {
    this.weekOffset = 0
    this.monthOffset = 0
    this.fullLabels = []
    this.mode = "week"
    this.initChart()
    this.loadWeek(this.weekOffset)
    // スワイプ検知用
    this.startX = 0
    this.canvasTarget.addEventListener("touchstart", this.onTouchStart.bind(this))
    this.canvasTarget.addEventListener("touchend", this.onTouchEnd.bind(this))
  }

  showWeek() {
    this.mode = "week"
    this.weekOffset = 0
    this.loadWeek(this.weekOffset)
    this.updateTabStyles()
    this.updateNavLabels()
  }

  showMonth() {
    this.mode = "month"
    this.loadMonth()
    this.updateTabStyles()
    this.updateNavLabels()
  }

  updateTabStyles() {
    if (this.mode === "week") {
      this.weekTabTarget.classList.add("bg-blue-500", "text-white")
      this.weekTabTarget.classList.remove("bg-gray-300", "text-gray-700")

      this.monthTabTarget.classList.add("bg-gray-300", "text-gray-700")
      this.monthTabTarget.classList.remove("bg-blue-500", "text-white")
    } else {
      this.monthTabTarget.classList.add("bg-blue-500", "text-white")
      this.monthTabTarget.classList.remove("bg-gray-300", "text-gray-700")

      this.weekTabTarget.classList.add("bg-gray-300", "text-gray-700")
      this.weekTabTarget.classList.remove("bg-blue-500", "text-white")
    }
  }

  onTouchStart(e) {
    this.startX = e.changedTouches[0].screenX
  }

  onTouchEnd(e) {
    const endX = e.changedTouches[0].screenX
    const diff = endX - this.startX

    if (diff > 0) {
      this.mode === "week" ? this.prevWeek() : this.prevMonth()
    } else {
      this.mode === "week" ? this.nextWeek() : this.nextMonth()
    }

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
      data: {
        labels: [],
        datasets: [{
          label: '',
          data: [],
          backgroundColor: 'rgba(75, 192, 192, 0.6)'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              // タイトルは空にして本文だけにする場合
              title: () => "",
              label: (context) => {
                const index = context.dataIndex
                return this.fullLabels.length > 0
                  ? this.fullLabels[index] + ' の幸せの数: ' + context.parsed.y
                  : context.parsed.y
              }
            }
          },
          title: {
            display: true,
            text: "",
            font: { size: 16 },
            align: 'center'
          }
        },
        scales: {
          y: { beginAtZero: true }
        }
      }
    })
  }


  updateNavLabels() {
    if (this.mode === "week") {
      this.prevButtonTarget.textContent = "← 前の週"
      this.nextButtonTarget.textContent = "次の週 →"
    } else {
      this.prevButtonTarget.textContent = "← 前の月"
      this.nextButtonTarget.textContent = "次の月 →"
    }
  }

  loadWeek(offset) {
    fetch(`/home.json?week_offset=${offset}`)
      .then(res => res.json())
      .then(data => {
        const labels = data.map(d => d.label)
        this.fullLabels = data.map(d => d.full_label)
        const counts = data.map(d => d.count)

        this.chart.data.labels = labels
        this.chart.data.datasets[0].data = counts
        this.chart.options.plugins.title.text = `${this.fullLabels[0]} ~ ${this.fullLabels[6]}`
        this.chart.update()
      })
  }

  loadMonth() {
    fetch(`/month.json?month_offset=${this.monthOffset}`, { headers: { "Accept": "application/json" } })
      .then(res => res.json())
      .then(data => {
        const labels = data.map(d => d.label)
        this.fullLabels = data.map(d => d.full_label)
        const counts = data.map(d => d.count)

        const title = data.length > 0
          ? `${this.fullLabels[0]} ~ ${this.fullLabels[this.fullLabels.length - 1]}`
          : "1か月分の記録"

        const isMobile = window.innerWidth < 1024

        this.chart.data.labels = labels
        this.chart.data.datasets[0].data = counts
        this.chart.options.plugins.title.text = title

  if (isMobile) {
    this.chart.options.scales.x.ticks.autoSkip = false
    this.chart.options.scales.x.ticks.callback = function(_, index) {
      const day = parseInt(labels[index], 10)
      const isFirst = index === 0
      const isLast = index === labels.length - 1
      const lastDay = parseInt(labels[labels.length - 1], 10)

      let isFiveUnit = day % 5 === 0

      // 最終日が31なら「30」は除外
      if (lastDay === 31 && day === 30) {
        isFiveUnit = false
      }

      return (isFirst || isFiveUnit || isLast) ? labels[index] : ""
    }
  } else {
    this.chart.options.scales.x.ticks.autoSkip = false
    this.chart.options.scales.x.ticks.callback = (val, index) => labels[index]
  }

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

  prevMonth() {
    this.monthOffset--
    this.loadMonth(this.monthOffset)
  }

  nextMonth() {
    this.monthOffset++
    this.loadMonth(this.monthOffset)
  }

  prev() {
    if (this.mode === "week") {
      this.prevWeek()
    } else {
      this.prevMonth()
    }
  }

  next() {
    if (this.mode === "week") {
      this.nextWeek()
    } else {
      this.nextMonth()
    }
  }


  switchMode(mode) {
    this.mode = mode
    if (mode === "week") {
      this.loadWeek(this.weekOffset)
    } else {
      this.loadMonth(this.monthOffset)
    }
    this.updateTabStyles()
  }


}