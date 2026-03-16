#!/bin/bash
set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SKILL_DIR/.venv"

echo "=== GigaCheck Skill — Installation ==="
echo ""

# ── Check Python 3.11 ──────────────────────────────────────────────────────────
PYTHON_CMD=""
for cmd in python3.11 python3; do
    if command -v "$cmd" &>/dev/null; then
        ver=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        if [ "$ver" = "3.11" ]; then
            PYTHON_CMD="$cmd"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ Error: Python 3.11 is required but not found."
    echo "   macOS:  brew install python@3.11"
    echo "   Ubuntu: sudo apt install python3.11 python3.11-venv"
    exit 1
fi

PYTHON_VERSION=$("$PYTHON_CMD" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
echo "✅ Python $PYTHON_VERSION found ($PYTHON_CMD)"

# ── Create virtual environment ─────────────────────────────────────────────────
if [ -d "$VENV_DIR" ]; then
    echo "♻️  Virtual environment already exists at $VENV_DIR, skipping creation."
else
    echo "📦 Creating virtual environment at $VENV_DIR ..."
    "$PYTHON_CMD" -m venv "$VENV_DIR"
    echo "✅ Virtual environment created"
fi

# ── Install dependencies inside venv ──────────────────────────────────────────
echo ""
echo "📥 Installing dependencies..."

# Pin setuptools<81: gigacheck's setup.py uses pkg_resources, removed in setuptools 81+
"$VENV_DIR/bin/pip" install --upgrade pip "setuptools<81" wheel --quiet

# PyTorch 2.5.1: try CUDA first, fall back to CPU-only
"$VENV_DIR/bin/pip" install "torch==2.5.1" \
    --index-url https://download.pytorch.org/whl/cu118 --quiet 2>/dev/null || \
"$VENV_DIR/bin/pip" install "torch==2.5.1" --quiet

"$VENV_DIR/bin/pip" install \
    "transformers==4.55.0" \
    "accelerate==1.8.1" \
    "huggingface_hub" \
    "langdetect" \
    "numpy" \
    --quiet

# GigaCheck library (provides trust_remote_code model classes)
# --no-build-isolation: use venv's pinned setuptools (with pkg_resources)
# instead of pip downloading the latest setuptools into an isolated build env
"$VENV_DIR/bin/pip" install \
    "git+https://github.com/ai-forever/gigacheck" \
    --no-build-isolation --quiet

echo "✅ Dependencies installed"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Installation complete! ==="
echo ""
echo "Model will be downloaded from HuggingFace automatically on first run:"
echo "  - iitolstykh/GigaCheck-Classifier-Multi (~14GB, Mistral-7B based)"
echo ""
echo "Usage:"
echo "  $VENV_DIR/bin/python $SKILL_DIR/gigacheck_inference.py --text 'Your text here'"
echo "  $VENV_DIR/bin/python $SKILL_DIR/gigacheck_inference.py --file document.txt"
echo "  $VENV_DIR/bin/python $SKILL_DIR/gigacheck_inference.py --folder ./texts/"
