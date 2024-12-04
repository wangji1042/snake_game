defmodule SnakeGame.GameServer do
  use GenServer

  # Define the game container size
  # 容器宽度
  @container_width 20
  # 容器高度
  @container_height 20

  # State struct for Game (Optional: You may add other fields like score, etc.)
  defstruct snake: [], food: [], direction: :right, score: 0

  # Start the GenServer with initial state
  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{
        snake: initial_snake(),
        food: generate_food(),
        direction: :right,
        score: 0
      },
      name: __MODULE__
    )
  end

  # Initialize the GenServer state
  def init(state) do
    {:ok, state}
  end

  # Initial snake state
  defp initial_snake do
    # 随机位置
    x = Enum.random(0..(@container_width - 1))
    y = Enum.random(0..(@container_height - 1))
    [{x, y}]
  end

  # Generate food
  defp generate_food do
    {Enum.random(0..(@container_width - 1)), Enum.random(0..(@container_height - 1))}
  end

  # Handle Change in Snake Direction
  def handle_cast({:change_direction, direction}, state) do
    # We allow direction change unless it's an opposite direction (avoid U-turns)
    new_direction =
      if valid_direction_change?(state.direction, direction) do
        direction
      else
        # Keep the same direction if invalid change
        state.direction
      end

    {:noreply, %{state | direction: new_direction}}
  end

  # Start the tick process when the game starts
  def handle_cast(:start_auto_tick, state) do
    # Initial tick
    # Start first tick after 1 second
    Process.send_after(self(), :tick, 1000)
    {:noreply, state}
  end

  # Function to start the automatic ticking in the game
  def start_game_auto_tick do
    GenServer.cast(__MODULE__, :start_auto_tick)
  end

  # 每秒钟自动更新游戏状态
  def handle_info(
        :tick,
        %__MODULE__{snake: snake, direction: direction, food: food, score: score} = state
      ) do
    case move_snake(snake, direction, food) do
      {:ok, new_snake, new_food} ->
        # 如果吃到了食物，增加积分
        new_score = if new_food != food, do: score + 1, else: score

        # 广播积分和状态
        broadcast_state(new_snake, new_food, new_score)

        # 设置下一次 tick
        Process.send_after(self(), :tick, 1000)

        {:noreply, %{state | snake: new_snake, food: new_food, score: new_score}}

      {:error, :out_of_bounds} ->
        # 游戏结束
        broadcast_game_over()
        {:stop, :normal, state}
    end
  end

  # Validate direction change (to prevent U-turns)
  defp valid_direction_change?(current_direction, new_direction) do
    case {current_direction, new_direction} do
      {:up, :down} -> false
      {:down, :up} -> false
      {:left, :right} -> false
      {:right, :left} -> false
      _ -> true
    end
  end

  # Movement logic for the snake
  defp move_snake(snake, direction, food) do
    # 未使用的变量用 `_tail`
    [{x, y} | _tail] = snake

    # 根据方向计算蛇的新头部
    new_head =
      case direction do
        :up -> {x, y - 1}
        :down -> {x, y + 1}
        :left -> {x - 1, y}
        :right -> {x + 1, y}
      end

    if out_of_bounds?(new_head) do
      {:error, :out_of_bounds}
    else
      # 如果吃到食物
      if new_head == food do
        # 增长蛇，生成新食物
        {:ok, [new_head | snake], generate_food()}
      else
        # 正常移动，保持长度
        {:ok, [new_head | Enum.drop(snake, -1)], food}
      end
    end
  end

  # 边界检测函数
  defp out_of_bounds?({x, y}) do
    x < 0 or y < 0 or x >= @container_width or y >= @container_height
  end

  # Check if snake has eaten the food and generate new food
  # defp check_food(snake, food) do
  #   if hd(snake) == food do
  #     # Generate new food if snake eats it
  #     generate_food()
  #   else
  #     # Otherwise, no change in food position
  #     food
  #   end
  # end

  # Collision detection logic (simple example)
  # defp collision?(snake) do
  #   [head | tail] = snake
  #   # Check if the snake has collided with itself
  #   head in tail
  # end

  # 广播游戏状态，包括蛇的位置、食物的位置和分数
  defp broadcast_state(snake, food, score) do
    SnakeGameWeb.Endpoint.broadcast("game:lobby", "game_update", %{
      # 将蛇的元组转换为列表
      snake: Enum.map(snake, fn {x, y} -> [x, y] end),
      # 将食物元组转换为列表
      food: Tuple.to_list(food),
      # 广播分数
      score: score
    })
  end

  # 广播游戏结束消息
  defp broadcast_game_over do
    SnakeGameWeb.Endpoint.broadcast("game:lobby", "game_over", %{
      message: "Game Over! You hit the wall."
    })
  end
end
