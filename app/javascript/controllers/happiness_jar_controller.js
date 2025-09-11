import { Controller } from "@hotwired/stimulus"
// import Matter from "matter-js" ← これを削除

export default class extends Controller {
  static values = {
    imageUrls: Array
  }

  connect() {
    console.log("=== HappinessJar connected ===")
    console.log("imageUrlsValue:", this.imageUrlsValue)
    console.log("Matter availability:", typeof Matter)

    if (typeof Matter === 'undefined') {
      console.error("Matter.js not loaded from CDN")
      return
    }

    const canvas = this.element.querySelector("#bottleCanvas")
    if (!canvas) {
      console.error("Canvas element not found")
      return
    }

    // 画像プリロード処理
    console.log("Starting image preload...")
    this.preloadImages(this.imageUrlsValue).then(loadedImages => {
      this.images = loadedImages
      console.log("✅ Images successfully preloaded:", this.images.length)
      
      // Matter.js セットアップ
      this.setupMatterJS(canvas)
    }).catch(err => {
      console.error("❌ Image preload failed:", err)
      this.setupMatterJS(canvas)
    })
  }

  preloadImages(urls) {
    console.log("Preloading images:", urls)
    const promises = urls.map((url, index) => {
      return new Promise((resolve, reject) => {
        const img = new Image()
        img.onload = () => {
          console.log(`✅ Image ${index + 1} loaded:`, url)
          resolve(img)
        }
        img.onerror = (error) => {
          console.error(`❌ Failed to load image ${index + 1}:`, url, error)
          reject(new Error(`Failed to load ${url}`))
        }
        img.src = url
      })
    })
    return Promise.all(promises)
  }

  setupMatterJS(canvas) {
    console.log("Setting up Matter.js...")
    this.engine = Matter.Engine.create()
    this.render = Matter.Render.create({
      canvas: canvas,
      engine: this.engine,
      options: {
        width: 300,
        height: 450,
        wireframes: false,
        background: "transparent"
      }
    })
    Matter.Render.run(this.render)
    Matter.Runner.run(Matter.Runner.create(), this.engine)

    this.marbles = []
    this.createBottleBounds()
    console.log("✅ Matter.js setup complete")
  }

  createBottleBounds() {
    const width = this.render.options.width
    const height = this.render.options.height
    const thickness = 20

    const ground = Matter.Bodies.rectangle(width / 2, height + thickness / 2, width, thickness, { isStatic: true })
    const leftWall = Matter.Bodies.rectangle(-thickness / 2, height / 2, thickness, height, { isStatic: true })
    const rightWall = Matter.Bodies.rectangle(width + thickness / 2, height / 2, thickness, height, { isStatic: true })

    Matter.World.add(this.engine.world, [ground, leftWall, rightWall])
  }

  addMarble() {
    console.log("=== addMarble called! ===")
    
    if (!this.engine) {
      console.error("Engine not available")
      return
    }

    // プリロード済み画像を使用
    if (!this.images || this.images.length === 0) {
      console.error("Images not loaded yet")
      return
    }

    const randomIndex = Math.floor(Math.random() * this.images.length)
    const selectedImage = this.images[randomIndex]
    
    console.log("Selected image:", selectedImage.src)

    const marble = Matter.Bodies.circle(150, 50, 25, {
      render: {
        sprite: {
          texture: selectedImage.src,
          xScale: 0.06,
          yScale: 0.06
        }
      },
      friction: 0.1,
      restitution: 0.5
    })

    Matter.World.add(this.engine.world, marble)
    this.marbles.push(marble)
    console.log("Image marble added successfully!")
  }
}

