import gymnasium as gym
# import gymnasium_robotics
import gymnasium_robotics.envs.fetch  # 👈 Add this line
import imageio

# # List all environments that belong to gymnasium_robotics
# robotics_envs = [spec.id for spec in gym.envs.registry.values()]
# robotics_envs.sort()

# for env_id in robotics_envs:
#     print(env_id)

env = gym.make("FetchReach-v4", render_mode="rgb_array")
obs, _ = env.reset()
frames = []

for _ in range(100):
    obs, _, terminated, truncated, _ = env.step(env.action_space.sample())
    frames.append(env.render())
    if terminated or truncated:
        break

env.close()
imageio.mimsave("test_headless_video.mp4", frames, fps=30)
print("🎉 Render test complete. Saved as test_headless_video.mp4")