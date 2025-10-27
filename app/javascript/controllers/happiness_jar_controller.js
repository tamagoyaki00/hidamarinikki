import { Controller } from "@hotwired/stimulus"
import confetti from "canvas-confetti"

export default class extends Controller {
  static values = {
    imageUrls: Array,
    contents: Array,
    addedIds: Array,
    deletedIds: Array,
  }

  connect() {
    this.overflowQueue = []

    const canvas = this.element.querySelector("#happiness-canvas")
    if (!canvas) return

    const contents = Array.isArray(this.contentsValue) ? this.contentsValue : []
    const urls = contents.map(c => c.happiness_image)

    if (urls.length > 0) {
      this.preloadImages(urls).then(loadedImages => {
        this.images = loadedImages
        this.contents = contents
        this.setupMatterJS(canvas)
        this.displayExistingHappiness()
        this.handleAnimationOnConnect()
      }).catch(() => {
        this.contents = contents
        this.setupMatterJS(canvas)
        this.displayExistingHappiness()
        this.handleAnimationOnConnect()
      })
    } else {
      this.contents = contents
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
    const addedIds = this.addedIdsValue || []
    this.contents.forEach((content, i) => {
      // リロード時は addedIds が空なので全件描画される
      if (addedIds.length === 0 || !addedIds.includes(content.id)) {
        this.addStaticHappiness(i)
      }
    })
  }


  capacity = 120

  // アニメーションの開始
  handleAnimationOnConnect() {
    // 追加アニメーション
    if (this.addedIdsValue?.length > 0) {
      this.addedIdsValue.forEach((id, i) => {
        setTimeout(() => {
          this.handleAddById(id)
        }, i * 350)
      })
    }

    // 削除アニメーション
    if (this.deletedIdsValue?.length > 0) {
      this.handleDecreaseAnimation(this.deletedIdsValue)
    }
  }

  // IDを指定して追加処理を行う（共通化）
  handleAddById(id) {
    const index = this.contents.findIndex(c => c.id === id)
    if (index === -1) return

    if (this.happinessList.length < this.capacity) {
      this.addAnimatedHappiness(index)

      if (this.happinessList.length >= this.capacity) {
        this.onJarFull()
      }
    } else {
      // 満杯ならオーバーフロー分をキューへ
      this.overflowQueue.push(index)
    }
  }

  // 削除アニメーション
  handleDecreaseAnimation(deletedIds) {
    deletedIds.forEach((id, i) => {
      setTimeout(() => {
        this.removeHappinessById(id)
      }, i * 300)
    })
  }

  // アニメーション付きで削除
  removeHappinessById(id) {
    const index = this.happinessList.findIndex(h => h.id === id)
    if (index === -1) return

    const happinessToRemove = this.happinessList.splice(index, 1)[0]
    Matter.Body.applyForce(
      happinessToRemove,
      happinessToRemove.position,
      { x: 0, y: -0.02 }
    )
    setTimeout(() => {
      Matter.World.remove(this.engine.world, happinessToRemove)
    }, 300)
  }



  // 既存データ用の静的表示
  addStaticHappiness(itemIndex) {
    
    // 位置を計算
    const pos = this.calculateStaticPosition(itemIndex)
    const content = this.contents[itemIndex]
    

    const filename = content.happiness_image
      ? content.happiness_image.split("/").pop()
      : null

    let selectedImg = this.images.find(img => {
      return filename && img.src.includes(filename)
    })


    if (!selectedImg && this.images && this.images.length > 0) {
      selectedImg = this.images[itemIndex % this.images.length]
    }


    if (selectedImg) {
      const size = 45
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
      happiness.id = content.id
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
    fallback.id = content.id 
    fallback.isExisting = true
    fallback.itemIndex = itemIndex
    Matter.World.add(this.engine.world, fallback)
    this.happinessList.push(fallback)
  }
  // 静的表示の位置計算
  calculateStaticPosition(itemIndex) {
    const cols = 7
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

  // 追加アニメーション用
  addAnimatedHappiness(itemIndex) {
    if (!this.engine) return
    const content = this.contents[itemIndex]
    const selectedImg = this.images.find(img => img.src.includes(content.happiness_image))

    if (selectedImg) {
      const size = 45
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
      happiness.id = content.id
      happiness.isAnimated = true
      happiness.itemIndex = itemIndex
      Matter.World.add(this.engine.world, happiness)
      this.happinessList.push(happiness)
      return happiness
    }

    // fallback
    const fallback = Matter.Bodies.circle(150, 50, 25, {
      render: { fillStyle: "#ff9999" },
      friction: 0.1,
      restitution: 0.5
    })
    fallback.id = content.id
    fallback.isAnimated = true
    fallback.itemIndex = itemIndex

    Matter.World.add(this.engine.world, fallback)
    this.happinessList.push(fallback)
    return fallback
  }


  onJarFull() {
    // コンフェッティ
    confetti({ particleCount: 120, spread: 70, origin: { y: 0.6 } })

    // モーダルを表示
    const modalToggle = document.getElementById("full-jar-modal")
    if (modalToggle) modalToggle.checked = true

    // フォールバック: 15秒後に自動で新しい瓶へ
    this.autoReplaceTimer = setTimeout(() => {
      this.replaceWithNewBottle()
      if (modalToggle) modalToggle.checked = false
    }, 15000)

    // 「次の瓶へ」ボタンにイベントを付与
    const button = document.getElementById("next-jar-button")
    if (button) {
      button.addEventListener("click", () => {
        clearTimeout(this.autoReplaceTimer) // 自動遷移をキャンセル
        this.replaceWithNewBottle()
        if (modalToggle) modalToggle.checked = false // ← モーダルを閉じる
      }, { once: true }) // ← 複数回バインド防止
    }
  }



  replaceWithNewBottle() {
    // Matter.js のワールドをクリア
    Matter.World.clear(this.engine.world, false)
    Matter.Engine.clear(this.engine)

    // 古い瓶を削除
    const oldBottle = document.getElementById("bottle-container")
    if (oldBottle) {
      oldBottle.remove()
    }

    // 新しい瓶を DOM に追加
    const container = this.element.querySelector(".w-full.flex.justify-center")
    const newBottle = document.createElement("div")
    newBottle.id = "bottle-container"
    newBottle.className = "relative w-[300px] h-[450px] border-2 border-accent rounded-md bg-base-200 bg-opacity-70 shadow-lg overflow-hidden"

    const newCanvas = document.createElement("canvas")
    newCanvas.id = "happiness-canvas"
    newCanvas.width = 300
    newCanvas.height = 450
    newCanvas.style = "position: absolute; top: 0; left: 0; z-index: 1;"

    newBottle.appendChild(newCanvas)
    container.appendChild(newBottle)

    // Matter.js を新しいキャンバスで再初期化
    this.happinessList = []
    this.setupMatterJS(newCanvas)

    // キューに溜まっていた分を新瓶へ流し込む
    const carry = [...this.overflowQueue]
    this.overflowQueue = []

    carry.forEach((itemIndex, idx) => {
      setTimeout(() => {
        this.addAnimatedHappiness(itemIndex)
        if (this.happinessList.length >= this.capacity) {
          this.onJarFull()
        }
      }, idx * 350)
    })
  }

}
