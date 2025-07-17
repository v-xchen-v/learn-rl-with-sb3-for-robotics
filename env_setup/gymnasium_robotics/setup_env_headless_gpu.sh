#!/bin/bash

set -e

# ====== CONFIG ====== #
# ENV_NAME=${1:-rl_sb3_robotics_env}
ENV_NAME=${1:-sb3_rl_robotics_env}
VIDEO_TEST=${2:-true}
TMP_DIR="tmp_gymnasium_robotics"

echo "🔧 Setting up Conda environment: $ENV_NAME"
echo "📹 Run video rendering test: $VIDEO_TEST"

# ====== 1. System Dependencies (Headless EGL) ====== #
echo "🧱 Installing system dependencies for EGL headless rendering..."
sudo apt update
sudo apt install -y \
    libgl1-mesa-glx libosmesa6 libglfw3 libglew-dev \
    libegl1 ffmpeg patchelf git

# ====== 2. Check Conda ====== #
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Miniconda or Anaconda."
    exit 1
fi

# ====== 3. Remove Existing Environment (Optional) ====== #
if conda env list | grep -q "$ENV_NAME"; then
    echo "⚠️ Environment '$ENV_NAME' already exists. Removing..."
    conda remove -n "$ENV_NAME" --all -y
fi

# ====== 4. Create Conda Environment ====== #
echo "📥 Creating new Conda environment: $ENV_NAME"
conda create -n "$ENV_NAME" python=3.10 -y

# ====== 5. Activate Conda Environment ====== #
echo "📂 Activating $ENV_NAME..."
eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

# ====== 6. Install Core RL Packages ====== #
echo "📦 Installing core RL packages..."
pip install --upgrade pip
pip install "stable-baselines3>=2.1.0"

# ====== 7. Install Gymnasium-Robotics (in temp dir) and mujoco ======#
echo "📥 Cloning Gymnasium-Robotics into $TMP_DIR..."
git clone https://github.com/Farama-Foundation/Gymnasium-Robotics.git "$TMP_DIR"

echo "🔧 Installing Gymnasium-Robotics..."
cd "$TMP_DIR"
pip install -e .
cd ..

# echo "🧹 Removing temporary folder..."
rm -rf "$TMP_DIR"

pip install mujoco

# ====== 8. Install Rendering and Video Tools ====== #
echo "🎥 Installing rendering and video libraries..."
pip install \
    imageio[ffmpeg]

# ====== 9. Install Dev Tools (Jupyter, Logging, Debugging) ====== #
echo "🧪 Installing development tools..."
pip install \
    jupyterlab ipykernel \
    tensorboard wandb \
    matplotlib pandas tqdm

# ====== 10. Export Headless Rendering Mode ====== #
export MUJOCO_GL=egl
echo "🧠 MUJOCO_GL=egl exported for headless rendering"

# ====== 11. Optional Render Test ====== #
if [ "$VIDEO_TEST" = true ]; then
    echo "🧪 Running headless rendering test..."
    python - <<EOF
import gymnasium as gym
import gymnasium_robotics
import imageio

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
EOF
fi

echo "✅ All setup complete!"
echo "🔑 To activate the environment later: conda activate $ENV_NAME"