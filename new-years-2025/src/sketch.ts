// @ts-ignore
import p5 from "p5";
import Firework from "./Firework.js";

const sketch = (p: p5)=> {
    const gravity = p.createVector(0, 0.25);
    let fireworks = [];
    let textHue = p.random(255);
    let speed = 5;
    let showHelpText = false;

    const helpTexts: string[] = [
        "Click or tap to spawn fireworks",
        "Press <r> to reset all fireworks",
        "Press <s> to save a screenshot",
        "Press <h> to toggle help text",
        "Press 1–9 to set speed slowest to fastest",
    ];

    function createFirework() {
        fireworks.push(new Firework(p, gravity));
    }

    p.windowResized = () => {
        p.resizeCanvas(p.windowWidth, p.windowHeight);
        recalculateBgImage();
    };

    p.mouseClicked = createFirework;

    p.touchStarted = createFirework;

    p.keyTyped = (evt) => {
        if (evt.key === "h" || evt.key === "H" || evt.key === "?") {
            showHelpText = !showHelpText;
            return;
        }
        if (evt.key === "r" || evt.key === "R") {
            fireworks = [];
            p.background(0);
            return;
        }
        if (evt.key === "s" || evt.key === "S") {
            p.saveCanvas("new-years-2025", "png");
            return;
        }
        const qty = parseInt(evt.key);
        if (qty >= 1 && qty <= 9) {
            speed = qty;
        }
    };

    let bgImage: p5.Image;
    let fgImage: p5.Image;
    p.preload = () => {
        bgImage = p.loadImage("./tokyo-skyline-cropped-final-bg.png");
        fgImage = p.loadImage("./tokyo-skyline-cropped-final-fg.png");
    };

    let bgImageAspect = 5906 / 1820; // Width / Height
    let bgImageWidth = 0;
    let bgImageHeight = 0;
    let bgImageXOffset = 0;
    let bgImageYOffset = 0;
    function recalculateBgImage() {
        p.imageMode(p.CORNERS);

        let scalingFactor = 1;
        if (p.width < p.height) {
            scalingFactor = 1.5;
        }

        bgImageWidth = p.width * scalingFactor;
        bgImageHeight = p.width / bgImageAspect * scalingFactor;

        bgImageXOffset = (p.width - bgImageWidth) / 2;
        bgImageYOffset = p.height - bgImageHeight;
    }

    p.setup = () => {
        const canvas = p.createCanvas(p.windowWidth, p.windowHeight);
        canvas.parent("draw");

        p.frameRate(60);
        p.colorMode(p.HSB);
        p.stroke(255);
        p.strokeWeight(4);
        p.background(0);

        recalculateBgImage();
    };

    p.draw = () => {
        p.push();
        p.colorMode(p.RGB);
        p.background(11, 11, 11, 30);
        p.image(bgImage, bgImageXOffset, bgImageYOffset, bgImageWidth + bgImageXOffset, bgImageHeight + bgImageYOffset);
        p.pop();

        const scene = p.random(1);
        if (scene < 0.001 * speed) {
            for (let i = 0; i < p.random(2, 8); i++) {
                createFirework();
            }
        } else if (scene < 0.006 * speed) {
            createFirework();
        } else if (p.frameCount % 120 == 119 && fireworks.length < 5) {
            for (let i = 0; i < 5; i++) {
                createFirework();
            }
        }

        fireworks.forEach(firework => {
            firework.update();
            firework.draw();
        });
        fireworks = fireworks.filter(firework => !firework.isDone());

        p.push();
        p.image(fgImage, bgImageXOffset, bgImageYOffset, bgImageWidth + bgImageXOffset, bgImageHeight + bgImageYOffset);
        p.pop();

        p.push();
        if (p.frameCount % 60 === 0) {
            textHue = (textHue + p.random(10, 30)) % 255;
        }
        p.fill(textHue, 255, 50);
        p.textFont("Bungee")
        p.strokeWeight(5);
        p.textSize(30);
        p.textStyle(p.BOLD);
        p.text("Happy New Year 2025! 🎉", 25, 40);

        p.strokeWeight(3);
        p.textSize(24);
        p.text("    f r o m   R i p t a   &   J a m e s", 25, 70);
        p.pop();

        if (showHelpText) {
            const idx = Math.trunc(p.frameCount / 500) % helpTexts.length;
            p.push();
            p.fill(0, 0, 100);
            p.textFont("Arial");
            p.strokeWeight(1);
            p.textSize(18);
            p.textStyle(p.NORMAL);
            p.text(helpTexts[idx], 25, 100);
            p.pop();
        }
    };
};

new p5(sketch);
