// assets/js/game.js
// import Phoenix from "phoenix";

let socket = new Phoenix.Socket("/socket", { params: {} });
socket.connect();

let gameChannel = socket.channel("game:lobby", {});
gameChannel
  .join()
  .receive("ok", (resp) => console.log("Joined successfully", resp))
  .receive("error", (resp) => console.log("Unable to join", resp));

let canvas = document.getElementById("gameCanvas");
let ctx = canvas.getContext("2d");

let tileSize = 20; // 每个方块的尺寸
let score = 0; // 分数

// 监听来自服务器的游戏状态更新
gameChannel.on("game_update", (gameState) => {
  console.log("game_update：", gameState);
  renderGame(gameState);
});

// 游戏结束
gameChannel.on("game_over", (gameState) => {
  console.log("game_over：", gameState);
  window.alert(gameState.message);
});

// 渲染游戏状态到画布
function renderGame(state) {
  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // 渲染蛇
  state.snake.forEach(([x, y]) => {
    ctx.fillStyle = "green";
    ctx.fillRect(x * tileSize, y * tileSize, tileSize, tileSize);
  });

  // 渲染食物
  let [foodX, foodY] = state.food;
  ctx.fillStyle = "red";
  ctx.fillRect(foodX * tileSize, foodY * tileSize, tileSize, tileSize);

  // 更新分数
  score = state.score;
  document.getElementById("score").textContent = "Score: " + score;
}

// 监听键盘事件来控制蛇的方向
document.addEventListener("keydown", (e) => {
  let direction = null;
  switch (e.key) {
    case "ArrowUp":
      direction = "up";
      break;
    case "ArrowDown":
      direction = "down";
      break;
    case "ArrowLeft":
      direction = "left";
      break;
    case "ArrowRight":
      direction = "right";
      break;
  }

  if (direction) {
    gameChannel.push("move", { direction: direction });
  }
});
