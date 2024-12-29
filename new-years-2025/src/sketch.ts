// @ts-ignore
import p5 from "p5";
import Circle from "./Circle.js";

const sketch = (p: p5)=> {
    const x = 100;
    const y = 100;

    const circles : Circle[] = [];

    p.setup = () => {
        const canvas = p.createCanvas(p.windowWidth, p.windowHeight);
        canvas.parent("draw");

        for (let i = 1; i < 4; i++) {
            const sz = canvas.width / 4;
            const circlePos = p.createVector(sz * i, canvas.height / 2);
            const size = i % 2 !== 0 ? 24 : 32;
            circles.push(new Circle(p, circlePos, size));
        }
    };

    p.draw = () => {
        p.background(51);
        p.fill(255);
        p.rect(x, y, 50, 50);
        circles.forEach(circle => circle.draw());
    };
};

new p5(sketch);
