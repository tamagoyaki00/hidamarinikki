import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    imageUrls: Array,
    existingCount: Number,
    animationType: String,
    animationCount: Number,
    previousTotal: Number
  }

  connect() {
    const canvas = this.element.querySelector("#happiness-canvas")
    if (!canvas) return

    const urls = Array.isArray(this.imageUrlsValue) ? this.imageUrlsValue : []

    if (urls.length > 0) {
      this.preloadImages(urls).then(loadedImages => {
        this.images = loadedImages
        this.setupMatterJS(canvas)
        this.displayExistingHappiness()
        this.handleAnimationOnConnect()
      }).catch(() => {
        this.images = []
        this.setupMatterJS(canvas)
        this.displayExistingHappiness()
        this.handleAnimationOnConnect()
      })
    } else {
      this.images = []
      this.setupMatterJS(canvas)
      this.displayExistingHappiness()
      this.handleAnimationOnConnect()
    }
  }

  preloadImages(urls) {
    const promises = urls.map((url) => {
      return new Promise((resolve, reject) => {
        const img = new Image()
        img.onload = () => resolve(img)
        img.onerror = () => reject(new Error(`Failed to load image: ${url}`))
        img.src = url
      })
    })
    return Promise.all(promises)
  }

  //matter.jsのセットアップ
  setupMatterJS(canvas) {
    this.engine = Matter.Engine.create()

    const width = canvas.width || 300
    const height = canvas.height || 450

    this.render = Matter.Render.create({
      canvas: canvas,
      engine: this.engine,
      options: {
        width: width,
        height: height,
        wireframes: false,
        background: "transparent"
      }
    })

    Matter.Render.run(this.render)
    this.runner = Matter.Runner.create()
    Matter.Runner.run(this.runner, this.engine)

    this.happinessList = []
    this.createBottleBounds()
  }

  // 瓶の壁を作成
  createBottleBounds() {
    const width = this.render.options.width
    const height = this.render.options.height
    const thickness = 15

    const ground = Matter.Bodies.rectangle(width / 2, height + thickness / 2, width, thickness, { isStatic: true })
    const leftWall = Matter.Bodies.rectangle(-thickness / 2, height / 2, thickness, height, { isStatic: true })
    const rightWall = Matter.Bodies.rectangle(width + thickness / 2, height / 2, thickness, height, { isStatic: true })

    Matter.World.add(this.engine.world, [ground, leftWall, rightWall])
  }

  // 既存のhappinessを表示
  displayExistingHappiness() {
    const previousTotal = Number(this.previousTotalValue || 0)
    for (let i = 0; i < previousTotal; i++) {
      this.addStaticHappiness(i)
    }
  }

  // アニメーションの開始
  handleAnimationOnConnect() {
    const type = this.animationTypeValue
    const count = Number(this.animationCountValue || 0)
    const prev = Number(this.previousTotalValue || 0)
    if (!type || count <= 0) return

    if (type === "increase") {
      this.handleIncreaseAnimation(prev, count)
    } else if (type === "decrease") {
      this.handleDecreaseAnimation(prev, count)
    }
  }

  // 追加アニメーション
  handleIncreaseAnimation(previousTotal, animationCount) {
    for (let i = 0; i < animationCount; i++) {
      setTimeout(() => {
        const itemIndex = previousTotal + i
        this.addAnimatedHappiness(itemIndex)
      }, i * 350)
    }
  }

  // 削除アニメーション
  handleDecreaseAnimation(previousTotal, animationCount) {
    for (let i = 0; i < animationCount; i++) {
      setTimeout(() => {
        this.removeHappinessWithAnimation()
      }, i * 300)
    }
  }

  // アニメーション付きで削除
  removeHappinessWithAnimation() {
    if (!this.happinessList || this.happinessList.length === 0) return
    const happinessToRemove = this.happinessList.pop()
    if (!happinessToRemove) return

    Matter.Body.applyForce(happinessToRemove, happinessToRemove.position, { x: 0, y: -0.02 })
    setTimeout(() => {
      Matter.World.remove(this.engine.world, happinessToRemove)
    }, 300)
  }

  // 既存データ用の静的表示
  addStaticHappiness(itemIndex) {
    // 位置を計算
    const pos = this.calculateStaticPosition(itemIndex)
    let selectedImg = null
    if (this.images && this.images.length > 0) {
      selectedImg = this.images[itemIndex % this.images.length]
    }

    if (selectedImg) {
      const size = 40
      const scaleX = selectedImg.width ? (size / selectedImg.width) : 0.06
      const scaleY = selectedImg.height ? (size / selectedImg.height) : 0.06
      const happiness = Matter.Bodies.circle(pos.x, pos.y, size / 2, {
        render: {
          sprite: {
            texture: selectedImg.src,
            xScale: scaleX,
            yScale: scaleY
          }
        },
        friction: 0.1,
        restitution: 0.5
      })
      happiness.isExisting = true
      happiness.itemIndex = itemIndex
      Matter.World.add(this.engine.world, happiness)
      this.happinessList.push(happiness)
      return
    }

    // 画像が表示されない時用
    const fallback = Matter.Bodies.circle(pos.x, pos.y, 25, {
      render: { fillStyle: "#cccccc" },
      friction: 0.1,
      restitution: 0.5
    })
    fallback.isExisting = true
    fallback.itemIndex = itemIndex
    Matter.World.add(this.engine.world, fallback)
    this.happinessList.push(fallback)
  }
  // 静的表示の位置計算
  calculateStaticPosition(itemIndex) {
    const cols = 4
    const row = Math.floor(itemIndex / cols)
    const col = itemIndex % cols

    const startX = 80
    const startY = this.render.options.height - 25
    const spacingX = 60
    const spacingY = 60

    return {
      x: startX + (col * spacingX),
      y: startY - (row * spacingY)
    }
  }

  // increaseアニメーション用
  addAnimatedHappiness(itemIndex) {
    if (!this.engine) return
    const selectedImg = (this.images && this.images.length > 0) ? this.images[itemIndex % this.images.length] : null

    if (selectedImg) {
      const size = 40
      const scaleX = selectedImg.width ? (size / selectedImg.width) : 0.06
      const scaleY = selectedImg.height ? (size / selectedImg.height) : 0.06
      const happiness = Matter.Bodies.circle(150, 50, size / 2, {
        render: {
          sprite: {
            texture: selectedImg.src,
            xScale: scaleX,
            yScale: scaleY
          }
        },
        friction: 0.1,
        restitution: 0.5
      })
      happiness.isAnimated = true
      happiness.itemIndex = itemIndex
      Matter.World.add(this.engine.world, happiness)
      this.happinessList.push(happiness)
      return
    }

    // fallback
    const fallback = Matter.Bodies.circle(150, 50, 25, {
      render: { fillStyle: "#ff9999" },
      friction: 0.1,
      restitution: 0.5
    })
    Matter.World.add(this.engine.world, fallback)
    this.happinessList.push(fallback)
  }


  checkIfFull(body) {
    const height = this.render.options.height
    const fullThresholdY = height * 0.1

    if (body.position.y <= fullThresholdY) {
      this.onJarFull()
    }
  }

  onJarFull() {
    console.log("Happiness jar is full!")
    // 🎉 ここでお祝い演出を呼び出す
  }
}
