---
name: setup
description: Install GigaCheck skill for Claude Code. Run this after cloning the repo. Handles Python check, venv creation, dependency installation, and skill registration.
user-invocable: true
---

# GigaCheck Setup

Automatically install the GigaCheck AI-text detection skill for Claude Code.

## Steps

### 1. Check Python 3.11

```bash
python3.11 --version
```

If Python 3.11 is not found, tell the user to install it:
- macOS: `brew install python@3.11`
- Ubuntu: `sudo apt install python3.11 python3.11-venv`

### 2. Register skill files

Copy the skill to the user's global Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/gigacheck_skill
cp SKILL.md gigacheck_inference.py install.sh requirements.txt ~/.claude/skills/gigacheck_skill/
```

### 3. Run install script from the skills directory

```bash
bash ~/.claude/skills/gigacheck_skill/install.sh
```

This creates an isolated `.venv/` inside `~/.claude/skills/gigacheck_skill/` and installs all dependencies (PyTorch, Transformers, GigaCheck, langdetect). Takes 2-5 minutes depending on network speed.

If installation fails:
- **"No module named venv"** → `sudo apt install python3.11-venv` (Linux)
- **PyTorch CUDA install fails** → normal on CPU-only machines, script falls back to CPU automatically
- **pip timeout** → retry, or check network connection

### 4. Verify

Run a quick test to confirm everything works:

```bash
~/.claude/skills/gigacheck_skill/.venv/bin/python -c "
import torch
from transformers import AutoConfig
print(f'PyTorch {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
config = AutoConfig.from_pretrained('iitolstykh/GigaCheck-Classifier-Multi', trust_remote_code=True)
print('GigaCheck config loaded successfully')
print()
print('Setup complete! Try: Check if this text is AI-generated: ...')
"
```

If this fails, check the install logs above for errors.

### 5. Done

Tell the user:

> GigaCheck skill is installed and ready. You can now use it from any Claude Code session:
>
> *"Check if this text is AI-generated: [paste your text here]"*
>
> The model (~14GB for Mistral-7B) will download automatically on first inference run.
>
> ⚠️ Only **English** and **Russian** texts are supported.
