#!/bin/bash
wget -qO- https://astral.sh/uv/install.sh | sh
alias uv="$HOME/.local/bin/uv"
alias ipython="python -m IPython --no-banner --config /home/coderpad/notconfig.py"

$HOME/.local/bin/uv init --no-package --no-managed-python --python $(which python)

$HOME/.local/bin/uv add --no-sync --no-cache --no-managed-python --python $(which python) ipython ruff polars plotnine pyarrow requests numpy ordered-set sortedcontainers

mkdir -p $HOME/.local/lib/python3.12/site-packages

$HOME/.local/bin/uv pip install -U --system --break-system-packages --no-managed-python --python $(which python) --no-build -e . --target $HOME/.local/lib/python3.12/site-packages/

# install takes ~ 1 minute
pkill -9 -f "node.*pyright"

mkdir -p /home/coderpad/.ipython/profile_default
python -m IPython profile create
touch notconfig.py
cat <<EOF > /home/coderpad/.ipython/profile_default/ipython_config.py
print("Loading config")
c.InteractiveShell.colors = 'Neutral'
c.InteractiveShell.xmode = 'Plain'
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalInteractiveShell.term_title = False
c.TerminalIPythonApp.display_banner = False
from IPython.terminal.prompts import Prompts, Token
import os
class CoderPadPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, '>>> ')]
    def continuation_prompt_tokens(self, cli=None, width=None):
        return [(Token.Prompt, '... ')]
c.TerminalInteractiveShell.prompts_class = CoderPadPrompt
c.BaseIPythonApplication.extra_config_file = "/home/coderpad/app/notconfig.py"
c.TerminalInteractiveShell.separate_in = ''
c.TerminalInteractiveShell.separate_out = ''
EOF

cat <<EOF > $HOME/app/src/main.example.py
# !pkill -9 -f "node.*pyright"
import sys
import pathlib
import requests
import numpy as np
import polars as pl
from polars import DataFrame
import plotnine as p9
from plotnine import aes, ggplot, geom_point
# needed by plotnine
sys.path.append(str(pathlib.Path("/home/coderpad/.local/bin")))
userlibs = f"/home/coderpad/.local/lib/python{sys.version_info.major}.{sys.version_info.minor}/site-packages/"
sys.path.append(userlibs)

## Python's missing Data Structures
# from collections import deque
# # Create a circular buffer with max length 5
# buffer = deque(maxlen=5) # buffer.append, buffer.pop(), buffer.lpop()
# for i in range(0)
# from ordered_set import OrderedSet # order of set insertion
# from sortedcontainers import SortedList # numeric order of value

def packages_avail():
  (ggplot(DataFrame({"x":[1], "y": [2]}), aes(x='x', y='y')) + geom_point()).save("test.png", verbose = False)
  print(paste_send("test.png"))
  np.array(1)
  return None

def paste_send(filename):
  with open(filename, 'rb') as f:
    data = {'reqtype': 'fileupload'}
    files = {'fileToUpload': f}
    response = requests.post('https://catbox.moe/user/api.php', data=data, files=files)
    response.raise_for_status()
    return response.text.strip()

if __name__ == "__main__":
  packages_avail()
  print("I am here")
  pass
EOF
rm -rf .git
rm -rf ./src/app.egg*
export TERM=xterm
python -m IPython --no-banner --config /home/coderpad/notconfig.py
