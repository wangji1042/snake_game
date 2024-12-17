defmodule SnakeGameWeb.GameChannel do
  use Phoenix.Channel

  intercept ["game_update", "game_over"]

  def join("game:lobby", _message, socket) do
    # send(self(), :after_join)

    # 让游戏开始自动更新
    SnakeGame.GameServer.start_game_auto_tick()

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    SnakeGame.GameServer.start_link(nil)
    {:noreply, socket}
  end

  # 用户控制蛇方向移动
  def handle_in("move", %{"direction" => direction}, socket) do
    # 将字符串转换为原子
    atom_direction = String.to_existing_atom(direction)

    # 向 GenServer 发送控制消息
    GenServer.cast(SnakeGame.GameServer, {:change_direction, atom_direction})
    {:noreply, socket}
  end

  def handle_out("game_update", game_state, socket) do
    push(socket, "game_update", game_state)
    {:noreply, socket}
  end

  def handle_out("game_over", game_state, socket) do
    push(socket, "game_over", game_state)
    {:noreply, socket}
  end
end
