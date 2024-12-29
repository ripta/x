// @ts-ignore
import p5 from "p5";

export default class Particle {
    private p: p5;
    private hue: number;
    private burst: boolean;
    private alpha: number;

    private pos: p5.Vector;
    private vel: p5.Vector;
    private acc: p5.Vector;

    constructor(p: p5, startPos: p5.Vector, vel: p5.Vector, acc: p5.Vector, hue: number, burst: boolean = false) {
        this.p = p;
        this.hue = hue;

        this.pos = startPos.copy();
        this.vel = vel.copy();
        this.acc = acc.copy();

        this.burst = burst;
        this.alpha = 255;
    }

    update() {
        if (this.burst) {
            this.vel.mult(0.85);
            this.alpha *= this.p.random(0.8, 0.975);
        }
        this.vel.add(this.acc);
        this.pos.add(this.vel);
    }

    draw() {
        const p = this.p;

        p.push();

        p.strokeWeight(4);
        if (this.burst) {
            p.strokeWeight(p.random(1, 3));
        }
        p.stroke(this.hue, 255, 255, this.alpha);
        p.point(this.pos.x, this.pos.y);

        p.pop();
    }

    isDone(): boolean {
        if (!this.burst) {
            return this.vel.y >= 0;
        }
        return this.alpha <= 3;
    }

    currentPos(): p5.Vector {
        return this.pos;
    }
}