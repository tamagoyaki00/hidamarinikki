import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    imageUrls: Array,
    newCount: Number
  }

  connect() {
    console.log("=== HappinessJar connected ===")
    console.log("imageUrlsValue:", this.imageUrlsValue)
    console.log("Matter availability:", typeof Matter)
    console.log("newCountValue:", this.newCountValue)

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
      
      this.setupMatterJS(canvas)
      
      // ✅ ここで自動実行を追加
      this.startAnimation()
    }).catch(err => {
      console.error("❌ Image preload failed:", err)
      this.setupMatterJS(canvas)
    })
  }

    startAnimation() {
    const newCount = this.newCountValue || 0
    console.log(`🎯 新しい幸せ: ${newCount}個`)
    
    if (newCount > 0) {
      console.log(`🎯 ${newCount}個の幸せを自動ドロップ開始！`)
      
      // 500ms間隔で順次ドロップ
      for (let i = 0; i < newCount; i++) {
        setTimeout(() => {
          console.log(`🎯 ${i + 1}個目の幸せをドロップ`)
          this.addMarble()
        }, i * 500)
      }
    } else {
      console.log("❌ 新しい幸せがないため、アニメーションなし")
    }
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


  getStaticPosition() {
    // 既存のmarbleを底から積み上げるように配置
    const layers = Math.floor(this.marbles.length / 8) // 1層あたり8個程度
    const yPosition = 400 - (layers * 55) // 底から55pxずつ上に
    return Math.max(yPosition, 100) // 上限を設定
  }

  // ✅ ランダムなX座標を取得
  getRandomX() {
    return Math.random() * 200 + 50 // 瓶の幅内でランダム
  }

  // ✅ アニメーション完了時の処理
  onAnimationComplete() {
    console.log("✅ All new marbles added successfully!")
    
    // 瓶がいっぱいかチェック（例：100個で満杯）
    if (this.marbles.length >= 100) {
      setTimeout(() => this.handleBottleFull(), 1000)
    }
    
    // 完了通知を表示
    this.showCompletionMessage()
  }

  // ✅ 瓶が満杯になった時の処理
  handleBottleFull() {
    console.log("🎉 Bottle is full!")
    
    // お祝いモーダルやエフェクトを表示
    const event = new CustomEvent('bottleFull', {
      detail: { totalCount: this.marbles.length }
    })
    this.element.dispatchEvent(event)
  }

  // ✅ 完了メッセージを表示
  showCompletionMessage() {
    const messageElement = this.element.querySelector('.completion-message')
    if (messageElement) {
      messageElement.textContent = `✨ ${this.newCountValue}個の幸せが追加されました！`
      messageElement.classList.add('show')
      
      // 3秒後に非表示
      setTimeout(() => {
        messageElement.classList.remove('show')
      }, 3000)
    }
  }

  disconnect() {
    // クリーンアップ
    if (this.render) {
      Matter.Render.stop(this.render)
    }
    if (this.engine) {
      Matter.Engine.clear(this.engine)
    }
  }
}

