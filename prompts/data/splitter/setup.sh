#!/usr/bin/env bash
# setup.sh — install dependencies on vast.ai (TensorFlow image, no PyTorch pre-installed)

# Detect the right pip/python
if [ -x /venv/main/bin/pip ]; then
    PIP=/venv/main/bin/pip
    PYTHON=/venv/main/bin/python3
elif [ -x /usr/local/bin/pip3 ]; then
    PIP=/usr/local/bin/pip3
    PYTHON=/usr/local/bin/python3
else
    PIP=pip3
    PYTHON=python3
fi
echo "pip:    $PIP"
echo "python: $PYTHON ($($PYTHON --version))"

echo ""
echo "=== GPU ==="
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader

echo ""
echo "=== ffmpeg ==="
if command -v ffmpeg &>/dev/null; then
    ffmpeg -version 2>&1 | head -1
    echo "ffmpeg already installed"
else
    echo "Installing ffmpeg..."
    apt-get update -qq && apt-get install -y ffmpeg
fi

echo ""
echo "=== PyTorch + torchaudio ==="
if $PYTHON -c "import torch; print(f'torch {torch.__version__} already present')" 2>/dev/null; then
    echo "Skipping torch install"
else
    echo "Installing torch + torchaudio (this downloads ~2.5 GB, will take a few minutes)..."
    $PIP install torch torchaudio --index-url https://download.pytorch.org/whl/cu121
    echo "torch install done"
fi

echo ""
echo "=== faster-whisper ==="
if $PYTHON -c "import faster_whisper; print('faster_whisper already present')" 2>/dev/null; then
    echo "Skipping"
else
    echo "Installing faster-whisper..."
    $PIP install faster-whisper
    echo "faster-whisper done"
fi

echo ""
echo "=== jiwer ==="
if $PYTHON -c "import jiwer; print('jiwer already present')" 2>/dev/null; then
    echo "Skipping"
else
    echo "Installing jiwer..."
    $PIP install jiwer
    echo "jiwer done"
fi

echo ""
echo "=== uroman (Lao → Latin romaniser for MMS_FA) ==="
if $PYTHON -c "import uroman; print('uroman already present')" 2>/dev/null; then
    echo "Skipping"
else
    echo "Installing uroman..."
    $PIP install uroman
    echo "uroman done"
fi

echo ""
echo "=== Final verification ==="
$PYTHON - <<'EOF'
import torch, torchaudio
from faster_whisper import WhisperModel
from jiwer import cer
import subprocess

print(f"torch        : {torch.__version__}")
print(f"torchaudio   : {torchaudio.__version__}")
print(f"CUDA         : {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU          : {torch.cuda.get_device_name(0)}")

import uroman as uroman_lib, unicodedata
bundle = torchaudio.pipelines.MMS_FA
try:
    labels = bundle.get_labels(star=None)
except TypeError:
    labels = bundle.get_labels()
print(f"MMS_FA vocab : {len(labels)} labels")

# Test: romanise Lao → align with MMS_FA tokenizer
ur = uroman_lib.Uroman()
roman = ur.romanize_string(unicodedata.normalize('NFC', 'ຂ້ອຍໄປໂຮງຮຽນ'), lcode='lao').lower().strip()
print(f"uroman test  : 'ຂ້ອຍໄປໂຮງຮຽນ' → '{roman}'")
tok = bundle.get_tokenizer()
ids = tok(roman)
print(f"MMS_FA tokens: {len(ids)} tokens — {'OK' if ids else 'FAIL'}")

r = subprocess.run(['ffmpeg', '-version'], capture_output=True)
print(f"ffmpeg       : {'OK' if r.returncode == 0 else 'MISSING'}")

print("")
print("=== Setup complete ===")
EOF
