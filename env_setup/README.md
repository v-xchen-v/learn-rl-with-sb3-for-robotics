# Environment Setup
This project supports 3 types of MuJoCo rendering backends, depending on your hardware setup, and two types of environments:

## Rendering Modes (MuJoCo)
| Mode            | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `headless-gpu` | For **remote servers with GPU** (e.g. cloud, SSH, Docker) — uses `EGL`      |
| `headless-cpu` | For **CPU-only servers** — uses software rendering via `OSMesa`             |
| `local-gui`    | For **local development machines** with GUI (e.g. laptop with display)      |

The rendering backend is controlled by setting the environment variable `MUJOCO_GL`:

- `MUJOCO_GL=egl` → Headless GPU
- `MUJOCO_GL=osmesa` → Headless CPU
- `MUJOCO_GL=glfw` → Local GUI (default for desktop use)

---

## 🎮 Environment Types

| Type                 | Description                                      | Examples                         |
|----------------------|--------------------------------------------------|----------------------------------|
| `gymnasium`          | Standard continuous control tasks                | `HalfCheetah-v5`, `Ant-v3`, etc. |
| `gymnasium-robotics` | Goal-conditioned robotic manipulation tasks      | `FetchPickAndPlace-v1`, etc.     |

---

# ⚙️ Setup Guide

> **Requirements**: Ubuntu, Conda, Python ≥ 3.10, NVIDIA drivers (for GPU setups)

## 1. Clone the repository

```bash
git clone https://github.com/yourname/learn-rl-with-sb3-for-robotics.git
cd learn-rl-with-sb3-for-robotics
```

## 2. Choose and run your setup script
```bash
# Format:
# ./env_setup/<env_type>/setup_<platform>.sh

# Examples:

# Gymnasium on GPU server
./env_setup/gymnasium/setup_gpu_headless.sh

# Gymnasium-Robotics on local machine with GUI
./env_setup/gymnasium_robotics/setup_local_gui.sh

# Gymnasium-Robotics on CPU-only server
./env_setup/gymnasium_robotics/setup_cpu_headless.sh
```

## 3. Activate the Conda environment
```bash
conda activate sb3_rl_env
# or
conda activate sb3_rl_robotics_env
```

## 4. (Optional) Verify headless rendering works
```
python env_setup/test_render.py          # for Gymnasium
python env_setup/test_robotics_render.py        # for Gymnasium-Robotics
```

## 📁 Script Structure
```
env_setup/
├── gymnasium/
│   ├── setup_gpu_headless.sh
│   ├── setup_cpu_headless.sh
│   └── setup_local_gui.sh
└── gymnasium_robotics/
    ├── setup_gpu_headless.sh
    ├── setup_cpu_headless.sh
    └── setup_local_gui.sh
```
Each script installs:

- Conda environment with stable-baselines3, mujoco, and either gymnasium or gymnasium-robotics

- Jupyter + logging tools (wandb, tensorboard, matplotlib, etc.)

- Headless rendering support for server use (if applicable)

# 🐞 Debugging with VSCode (Headless MuJoCo)
If you use VSCode, you can set up a launch configuration to automatically enable headless MuJoCo EGL rendering when debugging.

```
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "🐍 Debug MuJoCo Headless (EGL)",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "env": {
        "MUJOCO_GL": "egl",
        "MUJOCO_LOGLEVEL": "debug"
      }
    }
  ]
}
```
## ✅ How to Use
1. Open the script you want to run (e.g. main.py, train.py)

2. Click the debug dropdown in VSCode and choose "🐍 Debug MuJoCo Headless (EGL)"

3. Press F5 or click ▶️ Run and Debug

This runs your script with the correct environment variables for EGL-based headless rendering.