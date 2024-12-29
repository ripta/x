// @ts-ignore
import p5 from "p5";
import Firework from "./Firework.js";

const sketch = (p: p5)=> {
    const gravity = p.createVector(0, 0.25);
    var fireworks = [];
    var textHue = p.random(255);

    function createFirework() {
        fireworks.push(new Firework(p, gravity));
    }

    p.windowResized = () => {
        p.resizeCanvas(p.windowWidth, p.windowHeight);
    };

    p.mouseClicked = createFirework;

    p.touchStarted = createFirework;

    p.setup = () => {
        const canvas = p.createCanvas(p.windowWidth, p.windowHeight);
        canvas.parent("draw");

        p.frameRate(60);
        p.colorMode(p.HSB);
        p.stroke(255);
        p.strokeWeight(4);
        p.background(0);
    };

    p.draw = () => {
        p.push();
        p.colorMode(p.RGB);
        p.background(11, 11, 11, 50);
        p.pop();

        p.push();
        if (p.frameCount % 300 === 0) {
            textHue = p.random(255);
        }
        p.fill(textHue, 255, 50);
        p.textFont("Bungee")
        p.strokeWeight(5);
        p.textSize(30);
        p.text("Happy New Year 2025!", p.width / 5, p.height * 0.9 - 30);

        p.strokeWeight(3);
        p.textSize(18);
        p.text("Click / tap to make more fireworks", p.width / 5, p.height * 0.9);

        p.textSize(16);
        p.text(fireworks.length, 10, 30)
        p.pop();

        // p.text(p.frameRate(), 10, 10);

        const scene = p.random(1);
        if (scene < 0.005) {
            for (let i = 0; i < p.random(2, 8); i++) {
                createFirework();
            }
        } else if (scene < 0.03) {
            createFirework();
        }

        fireworks.forEach(firework => {
            firework.update();
            firework.draw();
        });
        fireworks = fireworks.filter(firework => !firework.isDone());
    };
};

new p5(sketch);
