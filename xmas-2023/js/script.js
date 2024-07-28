import * as THREE from 'three';
import { FontLoader } from 'three/addons/loaders/FontLoader.js';
import { TextGeometry } from 'three/addons/geometries/TextGeometry.js';

var particleLight;
var container;
var info;
var infoText = "Merry Christmas ~ From Ripta & James";
var infoColors = [];
var camera, scene, renderer, group;
var targetRotation = 0;
var targetRotationOnMouseDown = 0;
var mouseX = 0;
var mouseXOnMouseDown = 0;
var windowHalfX = window.innerWidth / 2;
var windowHalfY = window.innerHeight / 2;

// initialize and start animation
init();
animate();

function generateDataTexture(width, height, color) {
    var size = width * height;
    var data = new Uint8Array( 4 * size );

    var r = Math.floor( color.r * 255 );
    var g = Math.floor( color.g * 255 );
    var b = Math.floor( color.b * 255 );
    
    for (var i = 0; i < size; i++) {
        data[ i * 4 ] 	  = r;
        data[ i * 4 + 1 ] = g;
        data[ i * 4 + 2 ] = b;
        data[ i * 4 + 3 ] = 255;
    }

    var texture = new THREE.DataTexture( data, width, height, THREE.RGBAFormat );
    texture.needsUpdate = true;
    return texture;
}

function init() {

    // prepare the container
    container = document.createElement('div');
    document.body.appendChild(container);

    // display Info
    info = document.createElement('div');
    info.style.fontFamily = "Bungee,sans-serif";
    info.style.fontWeight = 400;
    //info.style.textTransform = "uppercase";
    info.style.color = "#ffffff";
    info.style.outlineColor = "#000000";
    info.style.position = 'absolute';
    info.style.bottom = '3em';
    info.style.width = '100%';
    info.style.textAlign = 'center';

    var infoLength = infoText.length;
    for (var i = 0; i < infoLength; i++) {
        infoColors.push("hsl(" + (360 * i / infoLength) + ",40%,50%");
    }
    for (var i = 0; i < infoLength; i++) {
        let el = document.createElement("span");
        el.style.color = infoColors[i];
        el.innerHTML = infoText[i];
        info.appendChild(el);
    }
    container.appendChild(info);

    // initialize the scene
    scene = new THREE.Scene();

    // add the fog
    scene.fog = new THREE.Fog(0xcce0ff, 500, 10000);

    // set the camera
    camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.set(0, 100, 500);
    scene.add(camera);

    // create the empty scene group
    group = new THREE.Object3D();
    scene.add(group);

    const tl = new THREE.TextureLoader();

    // prepare materials
    var imgTexture = tl.load('img/texture.jpg');
    imgTexture.repeat.set(1, 1);
    imgTexture.wrapS = imgTexture.wrapT = THREE.RepeatWrapping;
    imgTexture.anisotropy = 16;
    // imgTexture.needsUpdate = true;

    var shininess = 50;
    var specular = 0x333333;
    var bumpScale = 1;

    var materials = [];
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, bumpMap: imgTexture, bumpScale: bumpScale, color: 0xff0000, specular: specular, shininess: shininess} ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, color: 0x146B3A, specular: specular, shininess: shininess} ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, color: 0x584000 } ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, color: 0xffd700 } ) );
    //4
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, bumpMap: imgTexture, bumpScale: bumpScale, color: 0xD40028, specular: specular, shininess: shininess } ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, bumpMap: imgTexture, bumpScale: bumpScale, color: 0xEA4630, specular: specular, shininess: shininess } ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, bumpMap: imgTexture, bumpScale: bumpScale, color: 0x2A8FBD, specular: specular, shininess: shininess } ) );
    materials.push( new THREE.MeshPhongMaterial( { map: imgTexture, bumpMap: imgTexture, bumpScale: bumpScale, color: 0xC30022, specular: specular, shininess: shininess } ) );

    // add the Trunk
    var trunk = new THREE.Mesh(new THREE.CylinderGeometry(2, 20, 300, 30, 1, false), materials[2]);
    group.add(trunk);

    // add branch function
    function addBranch(count, x, y, z, opts, material, rotate) {

        // prepare star-like points
        var points = [], l;
        for (var i = 0; i < count * 2; i++) {
            if (i % 2 == 1) {
                l = count * 2;
            } else {
                l = count * 4;
            }
            var a = i / count * Math.PI;
            points.push( new THREE.Vector2(Math.cos(a) * l, Math.sin(a) * l));

            if (rotate && i % 2 == 0 && Math.random() > 0.6) {
                var sphGeometry = new THREE.SphereGeometry(8);
                var sphMesh = new THREE.Mesh(sphGeometry, materials[Math.floor(Math.random() * 4) + 4]);
                sphMesh.position.set(Math.cos(a) * l*1.25 *0.95, y-5, Math.sin(a) * l*1.25);
                group.add(sphMesh);
            }
        }

        var branchShape = new THREE.Shape(points);
        var branchGeometry = new THREE.ExtrudeGeometry(branchShape, opts);
        var branchMesh = new THREE.Mesh(branchGeometry, material);

        branchMesh.position.set(x, y, z);

        // rotate 90 degrees
        if (rotate) {
            branchMesh.rotation.set(Math.PI / 2, 0, 0);
        } else {
            branchMesh.rotation.set(0, 0, Math.PI / 2);
        }

        // add branch to the group
        group.add(branchMesh);
    }

    // options
    var options = {
        depth: 12,
        bevelEnabled: true,
        bevelSegments: 10,
        steps: 2
    };

    // add 10 branches
    var iBranchCnt = 20;
    for (var i1 = 0; i1 < iBranchCnt; i1++) {
        addBranch(iBranchCnt + 3 - i1, 0, -125 + i1*20, 0, options, materials[1], true);
    }

    // add the star
    var starOpts = {
        depth: 6,
        bevelEnabled: false
    };
    addBranch(7, 0, 280, -2, starOpts, materials[3], false);

    // add the ground
    //var groundColor = new THREE.Color(0xd2ddef);
    var groundColor = new THREE.Color(0x8c8177);
    var groundTexture = generateDataTexture(1, 1, groundColor);
    var groundMaterial = new THREE.MeshPhongMaterial({ color: 0xffffff, specular: 0x111111, map: groundTexture });

    var groundTexture = tl.load('img/ground.jpg', undefined, function() { groundMaterial.map = groundTexture });
    groundTexture.wrapS = groundTexture.wrapT = THREE.RepeatWrapping;
    groundTexture.repeat.set(25, 25);
    groundTexture.anisotropy = 16;

    var groundMesh = new THREE.Mesh( new THREE.PlaneGeometry(20000, 20000), groundMaterial);
    groundMesh.position.y = -150;
    groundMesh.rotation.x = - Math.PI / 2;
    group.add(groundMesh);

    // add snowflakes
    var sfMats = [];
    var sfTexture = tl.load('img/snowflake.png');
    var sfVertices = [];
    var sfCount = Math.floor(Math.random() * 2000) + 2000;
    for (var i = 0; i < sfCount; i++) {
        // var vertex = new THREE.Vector3();
        // vertex.x = Math.random() * 2000 - 1000;
        // vertex.y = Math.random() * 2000 - 1000;
        // vertex.z = Math.random() * 2000 - 1000;

        // sfVertices.push(vertex);
        sfVertices.push(Math.random() * 2000 - 1000);
        sfVertices.push(Math.random() * 2000 - 1000);
        sfVertices.push(Math.random() * 2000 - 1000);
    }

    var sfGeometry = new THREE.BufferGeometry();
    sfGeometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(sfVertices), 3));

    var states = [ [ [1.0, 0.2, 0.9], sfTexture, 10 ], [ [0.90, 0.1, 0.5], sfTexture, 8 ], [ [0.80, 0.05, 0.5], sfTexture, 5 ] ];
    for (var i = 0; i < states.length; i++) {
        var color  = states[i][0];
        var sprite = states[i][1];
        var size   = states[i][2];

        sfMats[i] = new THREE.PointsMaterial({ size: size, map: sprite, blending: THREE.AdditiveBlending, depthTest: false, transparent : true });
        sfMats[i].color.setHSL(color[0], color[1], color[2]);

        var particles = new THREE.Points(sfGeometry, sfMats[i]);

        particles.rotation.x = Math.random() * 10;
        particles.rotation.y = Math.random() * 10;
        particles.rotation.z = Math.random() * 10;

        group.add(particles);
    }

    const fl = new FontLoader();
    const grFont = fl.load('fonts/helvetiker_bold.typeface.json');
    const grText = new TextGeometry('Merry Christmas', {
        font: grFont,

        size: 100,
        height: 40,
        curveSegments: 4,

        bevelEnabled: true,
        bevelThickness: 2,
        bevelSize: 1.5,
        bevelOffset: 0,
        bevelSegments: 5,
    });

    grText.computeBoundingBox();

    const grMesh = new THREE.Mesh(grText, materials);
    grMesh.position.y = 400;
    //group.add(grMesh);

    // Add lights:

    // add ambient (global) light
    scene.add(new THREE.AmbientLight(0x999999));

    // add particle of light
    particleLight = new THREE.Mesh(new THREE.SphereGeometry(5, 10, 10), new THREE.MeshBasicMaterial({ color: 0xffffff }));
    particleLight.position.y = 400;
    group.add(particleLight);

    // add flying pint light
    var pointLight = new THREE.PointLight(0xffffff, 1, 1000);
    group.add(pointLight);

    pointLight.position.copy(particleLight.position);

    // add directional blue light
    var directionalLight = new THREE.DirectionalLight(0xffff00, 2);
    directionalLight.position.set(10, 1, 1).normalize();
    group.add(directionalLight);

    // prepare the render object and render the scene
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
    renderer.setClearColor(scene.fog.color);

    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);

    renderer.gammaInput = true;
    renderer.gammaOutput = true;
    renderer.physicallyBasedShading = true;

    // add events handlers
    document.addEventListener('mousedown', onDocumentMouseDown, false);
    document.addEventListener('touchstart', onDocumentTouchStart, false);
    document.addEventListener('touchmove', onDocumentTouchMove, false);
    window.addEventListener('resize', onWindowResize, false);
}

function onWindowResize() {

    windowHalfX = window.innerWidth / 2;
    windowHalfY = window.innerHeight / 2;

    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth - 20, window.innerHeight - 20 );
}

function onDocumentMouseDown(event) {
    event.preventDefault();

    document.addEventListener('mousemove', onDocumentMouseMove, false);
    document.addEventListener('mouseup', onDocumentMouseUp, false);
    document.addEventListener('mouseout', onDocumentMouseOut, false);

    mouseXOnMouseDown = event.clientX - windowHalfX;
    targetRotationOnMouseDown = targetRotation;
}

function onDocumentMouseMove(event) {
    mouseX = event.clientX - windowHalfX;
    targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02;
}

function onDocumentMouseUp(event) {
    document.removeEventListener('mousemove', onDocumentMouseMove, false);
    document.removeEventListener('mouseup', onDocumentMouseUp, false);
    document.removeEventListener('mouseout', onDocumentMouseOut, false);
}

function onDocumentMouseOut(event) {
    document.removeEventListener('mousemove', onDocumentMouseMove, false);
    document.removeEventListener('mouseup', onDocumentMouseUp, false);
    document.removeEventListener('mouseout', onDocumentMouseOut, false);
}

function onDocumentTouchStart(event) {
    if (event.touches.length == 1) {
        event.preventDefault();

        mouseXOnMouseDown = event.touches[0].pageX - windowHalfX;
        targetRotationOnMouseDown = targetRotation;
    }
}

function onDocumentTouchMove(event) {
    if (event.touches.length == 1) {
        event.preventDefault();

        mouseX = event.touches[0].pageX - windowHalfX;
        targetRotation = targetRotationOnMouseDown + (mouseX - mouseXOnMouseDown) * 0.02;
    }
}

function animate() {
    requestAnimationFrame(animate);

    render();
}

function render() {
    var timer = Date.now() * 0.00025;

    var infoLength = info.children.length;
    var colorOffset = Math.floor(Date.now() / 200) % infoLength;
    for (var i = 0; i < infoLength; i++) {
        info.children[i].style.color = infoColors[(i + colorOffset) % infoLength];
        if (i == colorOffset || i == (colorOffset - infoLength / 2) ) {
            info.children[i].style.fontSize = '32pt';
        } else {
            info.children[i].style.fontSize = '28pt';
        }
    }

    group.rotation.y += (targetRotation - group.rotation.y) * 0.01;

    //particleLight.position.x = Math.sin(timer * 7) * 300;
    //particleLight.position.z = Math.cos(timer * 3) * 300;
    particleLight.position.x = Math.cos(timer) * 300 + scene.position.x;
    particleLight.position.z = Math.sin(timer) * 300 + scene.position.z;

    // camera.position.x = Math.cos(timer) * 1000;
    // camera.position.z = Math.sin(timer) * 500;
    camera.position.x = Math.cos(timer) * 800 + scene.position.x;
    camera.position.z = Math.sin(timer) * 800 + scene.position.z;
    camera.lookAt(scene.position);

    renderer.render(scene, camera);
}
