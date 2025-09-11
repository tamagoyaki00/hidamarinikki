// import Matter from 'matter-js';

// document.addEventListener('DOMContentLoaded', () => {
//     const Engine = Matter.Engine;
//     const Render = Matter.Render;
//     const World = Matter.World;
//     const Bodies = Matter.Bodies;
//     const Events = Matter.Events;

//     const bottleContainer = document.getElementById('bottle-container');
//     const canvas = document.getElementById('bottleCanvas');
//     const addMarbleButton = document.getElementById('addMarbleButton');
//     const fullMessage = document.getElementById('fullMessage');

//     if (!bottleContainer || !canvas || !addMarbleButton || !fullMessage) {
//       console.error('必要なHTML要素が見つかりません。');
//       return;
//     }

//     const canvasWidth = bottleContainer.clientWidth;
//     const canvasHeight = bottleContainer.clientHeight;
//     canvas.width = canvasWidth;
//     canvas.height = canvasHeight;

//     const engine = Engine.create();
//     engine.world.gravity.y = 1;

//     const render = Render.create({
//         element: bottleContainer,
//         canvas: canvas,
//         engine: engine,
//         options: {
//             width: canvasWidth,
//             height: canvasHeight,
//             wireframes: false,
//             background: 'transparent'
//         }
//     });

//     const wallThickness = 20;
//     const walls = [
//         Bodies.rectangle(canvasWidth / 2, canvasHeight + wallThickness / 2, canvasWidth, wallThickness, { isStatic: true, render: { fillStyle: 'transparent' } }),
//         Bodies.rectangle(-wallThickness / 2, canvasHeight / 2, wallThickness, canvasHeight, { isStatic: true, render: { fillStyle: 'transparent' } }),
//         Bodies.rectangle(canvasWidth + wallThickness / 2, canvasHeight / 2, wallThickness, canvasHeight, { isStatic: true, render: { fillStyle: 'transparent' } }),
//     ];

//     const bottomCurveLeft = Bodies.rectangle(canvasWidth * 0.2, canvasHeight - wallThickness * 0.5, canvasWidth * 0.4, wallThickness, {
//         isStatic: true,
//         angle: Math.PI * 0.05,
//         render: { fillStyle: 'transparent' }
//     });
//     const bottomCurveRight = Bodies.rectangle(canvasWidth * 0.8, canvasHeight - wallThickness * 0.5, canvasWidth * 0.4, wallThickness, {
//         isStatic: true,
//         angle: -Math.PI * 0.05,
//         render: { fillStyle: 'transparent' }
//     });

//     World.add(engine.world, [...walls, bottomCurveLeft, bottomCurveRight]);

//     let isBottleFull = false;
//     const fullThresholdY = canvasHeight * 0.15;
//     const marbleRadius = 50 / 2;

//     const imageUrls = [
//         'green.png', 'orange.png', 'pink.png', 'star.png', 'heart.png', 'clover.png',
//     ];

//     function addMarble() {
//         if (isBottleFull) {
//             return;
//         }

//         const randomImageUrl = imageUrls[Math.floor(Math.random() * imageUrls.length)];

//         const size = 50;
//         const x = canvasWidth / 2 + (Math.random() - 0.5) * 50;
//         const y = -size;

//         const marble = Bodies.circle(x, y, size / 2, {
//             restitution: 0.7,
//             friction: 0.5,
//             render: {
//                 sprite: {
//                     texture: randomImageUrl,
//                     xScale: size / 720 * 0.9,
//                     yScale: size / 720 * 0.9
//                 }
//             },
//             label: 'marble'
//         });
//         World.add(engine.world, marble);
//     }

//     addMarbleButton.addEventListener('click', addMarble);

//     Engine.run(engine);
//     Render.run(render);

//     Events.on(engine, 'afterUpdate', () => {
//         if (isBottleFull) {
//             return;
//         }

//         let highestMarbleY = Infinity;

//         const bodies = World.getAllBodies(engine.world);
//         for (const body of bodies) {
//             if (body.label === 'marble') {
//                 const marbleTopY = body.position.y - body.circleRadius;
//                 if (marbleTopY < highestMarbleY) {
//                     highestMarbleY = marbleTopY;
//                 }
//             }
//         }

//         if (highestMarbleY <= fullThresholdY) {
//             isBottleFull = true;
//             addMarbleButton.disabled = true;
//             fullMessage.style.display = 'block';
//         }
//     });
// });