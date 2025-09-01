import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.canvas = this.canvasTarget;
    this.ctx = this.canvas.getContext("2d");
    this.width = this.canvas.width = window.innerWidth;
    this.height = this.canvas.height = window.innerHeight;

    window.addEventListener("resize", () => {
      this.width = this.canvas.width = window.innerWidth;
      this.height = this.canvas.height = window.innerHeight;
    });

    // 光の粒を作る
    this.particles = Array.from({ length: 20 }, () => ({
      x: Math.random() * this.width,
      y: this.height * (0.6 + Math.random() * 0.4),
      radius: Math.random() * 40 + 20,
      alpha: Math.random(),
      dAlpha: Math.random() * 0.01 + 0.002,
      speed: Math.random() * 0.4 + 0.1
    }));

    this.animate();
  }

  animate() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.width, this.height);

    this.particles.forEach(p => {
      p.alpha += p.dAlpha;
      if (p.alpha > 1) p.dAlpha *= -1;
      if (p.alpha < 0.3) {
        p.alpha = 0.3;
        p.dAlpha = Math.random() * 0.01 + 0.002;
        p.x = Math.random() * this.width;
        p.y = this.height;
      }

      p.y -= p.speed;
      if (p.y < -10) {
        p.y = this.height;
        p.x = Math.random() * this.width;
      }

      const gradient = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.radius);
      gradient.addColorStop(0, `rgba(255, 153, 102, ${p.alpha})`);
      gradient.addColorStop(0.5, `rgba(255, 199, 138, ${p.alpha * 0.7})`);
      gradient.addColorStop(1, `rgba(255, 250, 232, 0)`);
      ctx.fillStyle = gradient;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
      ctx.fill();
    });

    requestAnimationFrame(this.animate.bind(this));
  }
}
