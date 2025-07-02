#!/bin/bash

set -e

# ====== CONFIG ======#
ENV_NAME=${1:-sb3_rl_env}
# YML_FILE=${2:-environment.yml}
VIDEO_TEST=${3:-true}

echo "🔧 Setting up Conda environment: $ENV_NAME"
# echo "📄 Using environment file: $YML_FILE"
echo "📹 Run video rendering test: $VIDEO_TEST"

# ====== 1. System dependencies ======
echo "🧱 Installing system packages for headless rendering..."
sudo apt update
sudo apt install -y \
    libgl1-mesa-glx libosmesa6 libglfw3 libglew-dev \
    libegl1 ffmpeg patchelf git

# ====== 2. Check Conda ======
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Install Miniconda or Anaconda first."
    exit 1
fi

# ====== 3. Remove old env if exists ======
if conda env list | grep -q "$ENV_NAME"; then
    echo "⚠️ Environment $ENV_NAME already exists. Removing..."
    conda remove -n "$ENV_NAME" --all -y
fi

# ====== 4. Create Conda env ======
echo "📥 Creating Conda environment..."
conda create -n "$ENV_NAME" python=3.10 -y

# ====== 5. Activate Conda env ======
echo "📂 Activating $ENV_NAME..."
eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

# ====== 6. Install gym + mujoco ====
echo "Install gymnasium stable-baseline3..."
pip install gymnasium[mujoco]
pip install "stable-baselines3>=2.1.0"

# ====== 7. Install extra headless + video packages ======
echo "🎥 Installing rendering dependencies..."
pip install imageio[ffmpeg] numpy

# ====== 8. Install Jupyter, WandB, TensorBoard... ======
pip install \
    jupyterlab ipykernel \
    tensorboard wandb matplotlib pandas tqdm

# ====== 8. Export MUJOCO_GL headless mode ======
export MUJOCO_GL=egl
echo "🧠 MUJOCO_GL=egl exported for headless rendering"

# ====== 9. Optional: Test video rendering ======
if [ "$VIDEO_TEST" = true ]; then
    echo "🧪 Running headless rendering test..."
    python - <<EOF
import gymnasium as gym
import imageio

env = gym.make("HalfCheetah-v5", render_mode="rgb_array")
obs, _ = env.reset()
frames = []
for _ in range(100):
    obs, _, terminated, truncated, _ = env.step(env.action_space.sample())
    frames.append(env.render())
    if terminated or truncated:
        break
env.close()
imageio.mimsave("test_headless_video.mp4", frames, fps=30)
print("🎉 Render test complete. Saved: test_headless_video.mp4")
EOF
fi

echo "✅ All setup complete! To activate env: conda activate $ENV_NAME"