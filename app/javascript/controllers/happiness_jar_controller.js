// app/javascript/controllers/happiness_jar_controller.js
import { Controller } from "@hotwired/stimulus"
import Matter from "matter-js"

export default class extends Controller {
  static values = {
    imageUrls: Array,
    existingCount: Number,
    animationType: String,
    animationCount: Number,
    previousTotal: Number
  }

  connect() {
    console.log("HappinessJar connected")
    console.log("imageUrlsValue:", this.imageUrlsValue)

    if (typeof Matter === 'undefined') {
      console.error("Matter.js not loaded")
      return
    }

    const canvas = this.element.querySelector("#happiness-canvas")
    if (!canvas) {
      console.error("Canvas not found inside controller element")
      return
    }

    // Guard: imageUrlsValue may be undefined/empty — still proceed so we can show existing marbles if necessary
    const urls = Array.isArray(this.imageUrlsValue) ? this.imageUrlsValue : []
    console.log("preload candidate urls:", urls)

    // preload (if no urls, skip gracefully)
    if (urls.length > 0) {
      this.preloadImages(urls).then(loadedImages => {
        this.images = loadedImages
        console.log("✅ Images preloaded:", this.images.map(i => ({ src: i.src, w: i.width, h: i.height })))
        this.setupMatterJS(canvas)
        this.displayExistingMarbles()
        this.handleAnimationOnConnect()
      }).catch(err => {
        console.error("Image preload failed:", err)
        // even if preload fails, still setup Matter so we can at least use colored shapes for debug
        this.images = []
        this.setupMatterJS(canvas)
        this.displayExistingMarbles()
        this.handleAnimationOnConnect()
      })
    } else {
      // no images: setup Matter and show static marbles (using colored circles)
      this.images = []
      this.setupMatterJS(canvas)
      this.displayExistingMarbles()
      this.handleAnimationOnConnect()
    }
  }

  preloadImages(urls) {
    console.log("Preloading images:", urls)
    const promises = urls.map((url, idx) => {
      return new Promise((resolve, reject) => {
        const img = new Image()
        img.onload = () => {
          console.log(`Image loaded[${idx}]:`, url, img.width, img.height)
          resolve(img)
        }
        img.onerror = (err) => {
          console.error(`Image failed to load[${idx}]:`, url, err)
          reject(new Error(`Failed to load image: ${url}`))
        }
        img.src = url
      })
    })
    return Promise.all(promises)
  }

setupMatterJS(canvas) {
  console.log("Setting up Matter.js with canvas:", canvas)
  this.engine = Matter.Engine.create()

  // ✅ 念のため重力を設定
  this.engine.world.gravity.y = 1

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

  this.marbles = []
  this.createBottleBounds()
  console.log("✅ Matter.js setup complete, world bodies:", this.engine.world.bodies.length)

  // ✅ デバッグ: 毎フレーム重力確認
  Matter.Events.on(this.engine, "afterUpdate", () => {
    if (this.marbles.length > 0) {
      const y = this.marbles[this.marbles.length - 1].position.y
      console.log("Marble Y position:", y)
    }
  })
}

  createBottleBounds() {
    const width = this.render.options.width
    const height = this.render.options.height
    const thickness = 20

    // clear previous bounds? (optional) — here we simply add bounds once
    const ground = Matter.Bodies.rectangle(width / 2, height + thickness / 2, width, thickness, { isStatic: true })
    const leftWall = Matter.Bodies.rectangle(-thickness / 2, height / 2, thickness, height, { isStatic: true })
    const rightWall = Matter.Bodies.rectangle(width + thickness / 2, height / 2, thickness, height, { isStatic: true })

    Matter.World.add(this.engine.world, [ground, leftWall, rightWall])
    console.log("Bounds added. world bodies:", this.engine.world.bodies.length)
  }

  // Show existing marbles (use addStaticMarble which actually adds to world)
  displayExistingMarbles() {
    const previousTotal = Number(this.previousTotalValue || 0)
    console.log(`Displaying existing marbles count=${previousTotal}`)
    for (let i = 0; i < previousTotal; i++) {
      this.addStaticMarble(i)
    }
    console.log("After adding existing, world bodies:", this.engine?.world?.bodies.length)
  }

  // Animation entrypoint used on connect: decide increase/decrease/no-op
  handleAnimationOnConnect() {
    const type = this.animationTypeValue
    const count = Number(this.animationCountValue || 0)
    const prev = Number(this.previousTotalValue || 0)
    console.log("handleAnimationOnConnect:", { type, count, prev })
    if (!type || count <= 0) return

    if (type === "increase") {
      this.handleIncreaseAnimation(prev, count)
    } else if (type === "decrease") {
      this.handleDecreaseAnimation(prev, count)
    } else {
      console.log("Unknown animation type:", type)
    }
  }

  // increase animation: add 'count' marbles with staggered timeout
  handleIncreaseAnimation(previousTotal, animationCount) {
    console.log(`Starting increase animation: ${animationCount} marbles from index ${previousTotal}`)
    for (let i = 0; i < animationCount; i++) {
      setTimeout(() => {
        const itemIndex = previousTotal + i
        this.addAnimatedMarble(itemIndex)
      }, i * 350)
    }
  }

  // decrease animation: remove marbles one by one
  handleDecreaseAnimation(previousTotal, animationCount) {
    console.log(`Starting decrease animation: removing ${animationCount}`)
    for (let i = 0; i < animationCount; i++) {
      setTimeout(() => {
        this.removeMarbleWithAnimation()
      }, i * 300)
    }
  }

  // add a marble from the UI button (random image)
  addMarble() {
    console.log("addMarble called")
    if (!this.engine) {
      console.error("Engine not initialized")
      return
    }

    // If images were preloaded, use them. Otherwise fallback to a colored circle for debug
    if (this.images && this.images.length > 0) {
      const img = this.images[Math.floor(Math.random() * this.images.length)]
      console.log("Using image for marble:", img.src, img.width, img.height)

      const size = 50 // desired displayed diameter in px
      const scaleX = img.width ? (size / img.width) : 0.07
      const scaleY = img.height ? (size / img.height) : 0.07

      const marble = Matter.Bodies.circle(150, 50, 25, {
        render: {
          sprite: {
            texture: img.src,
            xScale: scaleX,
            yScale: scaleY
          }
        },
        friction: 0.1,
        restitution: 0.5
      })
      Matter.World.add(this.engine.world, marble)
      this.marbles.push(marble)
      console.log("Marble (image) added. world count:", this.engine.world.bodies.length)
      return
    }

    // fallback debug colored circle if images empty
    const size = 50
    const colors = ["#ff6666", "#66ff66", "#6666ff", "#ffd700"]
    const color = colors[Math.floor(Math.random() * colors.length)]
    const marble = Matter.Bodies.circle(150, -50, size / 2, {
      render: { fillStyle: color },
      friction: 0.1,
      restitution: 0.5
    })
    Matter.World.add(this.engine.world, marble)
    this.marbles.push(marble)
    console.log("Marble (fallback colored) added. world count:", this.engine.world.bodies.length)
  }

  // Remove with animation
  removeMarbleWithAnimation() {
    console.log("removeMarbleWithAnimation called")
    if (!this.marbles || this.marbles.length === 0) {
      console.warn("No marbles to remove")
      return
    }
    const marbleToRemove = this.marbles.pop()
    if (!marbleToRemove) return

    // small effect: apply upward force
    Matter.Body.applyForce(marbleToRemove, marbleToRemove.position, { x: 0, y: -0.02 })
    setTimeout(() => {
      Matter.World.remove(this.engine.world, marbleToRemove)
      console.log("Removed marble. world count:", this.engine.world.bodies.length)
    }, 300)
  }

  // Adds a static marble for existing data display
  addStaticMarble(itemIndex) {
    // position calculation
    const pos = this.calculateStaticPosition(itemIndex)
    let selectedImg = null
    if (this.images && this.images.length > 0) {
      selectedImg = this.images[itemIndex % this.images.length]
    }

    if (selectedImg) {
      const size = 50
      const scaleX = selectedImg.width ? (size / selectedImg.width) : 0.06
      const scaleY = selectedImg.height ? (size / selectedImg.height) : 0.06
      const marble = Matter.Bodies.circle(pos.x, pos.y, size / 2, {
        render: {
          sprite: {
            texture: selectedImg.src,
            xScale: scaleX,
            yScale: scaleY
          }
        }
      })
      marble.isExisting = true
      marble.itemIndex = itemIndex
      Matter.World.add(this.engine.world, marble)
      this.marbles.push(marble)
      console.log(`Added static image marble index=${itemIndex}`)
      return
    }

    // fallback colored static marble
    const fallback = Matter.Bodies.circle(pos.x, pos.y, 25, {
      isStatic: true,
      render: { fillStyle: "#cccccc" }
    })
    fallback.isExisting = true
    fallback.itemIndex = itemIndex
    Matter.World.add(this.engine.world, fallback)
    this.marbles.push(fallback)
    console.log(`Added fallback static marble index=${itemIndex}`)
  }

  calculateStaticPosition(itemIndex) {
    const cols = 4
    const row = Math.floor(itemIndex / cols)
    const col = itemIndex % cols

    const startX = 80
    const startY = this.render.options.height - 60
    const spacingX = 60
    const spacingY = 60

    return {
      x: startX + (col * spacingX),
      y: startY - (row * spacingY)
    }
  }

  // Add animated marble for "increase" sequence, itemIndex used to pick image
  addAnimatedMarble(itemIndex) {
    if (!this.engine) return
    const selectedImg = (this.images && this.images.length > 0) ? this.images[itemIndex % this.images.length] : null

    if (selectedImg) {
      const size = 50
      const scaleX = selectedImg.width ? (size / selectedImg.width) : 0.06
      const scaleY = selectedImg.height ? (size / selectedImg.height) : 0.06
      const marble = Matter.Bodies.circle(150, 50, size / 2, {
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
      marble.isAnimated = true
      marble.itemIndex = itemIndex
      Matter.World.add(this.engine.world, marble)
      this.marbles.push(marble)
      console.log("Added animated marble", itemIndex)
      return
    }

    // fallback
    const fallback = Matter.Bodies.circle(150, 50, 25, {
      render: { fillStyle: "#ff9999" },
      friction: 0.1,
      restitution: 0.5
    })
    Matter.World.add(this.engine.world, fallback)
    this.marbles.push(fallback)
    console.log("Added fallback animated marble", itemIndex)
  }
}
