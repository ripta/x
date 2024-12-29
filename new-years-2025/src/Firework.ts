// @ts-ignore
import p5 from "p5";
import Particle from "./Particle.js";

export default class Firework {
  private p: p5;
  private hue: number;
  private particles: Particle[] = [];
  private phase: number = 0;
  private gravity = p5.Vector;

  constructor(p: p5, gravity: p5.Vector) {
    this.p = p;
    this.hue = p.random(255);
    this.phase = 0;
    this.gravity = gravity;

    const startingPos = p.createVector(
      p.random(p.width * 0.1, p.width * 0.9),
      p.height,
    );
    const height = p.height / 10;
    const startingVel = p.createVector(
      0,
      p.randomGaussian(-height / 6, -height / 20),
    );
    const rocket = new Particle(p, startingPos, startingVel, gravity, this.hue);
    this.particles.push(rocket);
  }

  update() {
    if (
      this.phase === 0 &&
      this.particles.every((particle) => particle.isDone())
    ) {
      this.phase = 1;

      const startingPos = this.particles[0].currentPos();
      this.particles = [];

      const burstType = this.p.random(1);

      if (burstType < 0.5) {
        const burstCount = this.p.random(80, 110);
        for (let i = 0; i < burstCount; i++) {
          const startingVel = p5.Vector.random2D().mult(this.p.random(0.5, 8));
          const burst = new Particle(
            this.p,
            startingPos,
            startingVel,
            this.gravity,
            this.hue,
            true,
          );
          this.particles.push(burst);
        }
      } else if (burstType < 0.8) {
        const burstCount = this.p.random(20, 40);
        for (let i = 0; i < burstCount; i++) {
          const startingVel = p5.Vector.random2D().mult(this.p.random(7, 8));
          startingVel.y = -Math.abs(startingVel.y);
          const burst = new Particle(
            this.p,
            startingPos,
            startingVel,
            this.gravity,
            this.hue,
            true,
          );
          this.particles.push(burst);
        }
      } else if (burstType < 0.9) {
        for (let j = 1; j < 4; j++) {
          const burstCount = this.p.random(20, 40);
          for (let i = 0; i < burstCount; i++) {
            const startingVel = p5.Vector.random2D().mult(5 * j);
            const burst = new Particle(
              this.p,
              startingPos,
              startingVel,
              this.gravity,
              this.hue,
              true,
            );
            this.particles.push(burst);
          }
        }
      } else {
        const burstCount = this.p.random(20, 40);
        for (let i = 0; i < burstCount; i++) {
          const startingVel = p5.Vector.random2D().mult(this.p.random(22, 30));
          const burst = new Particle(
            this.p,
            startingPos,
            startingVel,
            this.gravity,
            this.hue,
            true,
          );
          this.particles.push(burst);
        }
      }
    }

    this.particles.forEach((particle) => {
      particle.update();
    });
  }

  draw() {
    this.particles.forEach((particle) => {
      particle.draw();
    });
  }

  isDone(): boolean {
    return (
      this.particles.length > 1 &&
      this.particles.every((particle) => particle.isDone())
    );
  }
}
