// @ts-ignore
import p5 from "p5";

export default class Circle {
  private p: p5;
  private pos: p5.Vector;
  private size: number;

  constructor(p: p5, pos: p5.Vector, size: number) {
    this.p = p;
    this.pos = pos;
    this.size = size;
  }

  draw() {
    const p = this.p;

    p.push();

    p.translate(this.pos);
    p.noStroke();
    p.fill("orange");
    p.ellipse(0, 0, this.size);

    p.pop();
  }
}
