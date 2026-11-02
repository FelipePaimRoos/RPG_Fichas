import json, re, sys
from pathlib import Path

# Caminhos a partir da pasta tests/
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

# HTML div balance
s = open(ROOT / 'ficha_rpg_completa.html', encoding='utf-8').read()
html = s.split('<script')[0]
print('html div balanced:', html.count('<div') == html.count('</div>'))

# JS syntax
m = re.findall(r'<script>(.*?)</script>', s, re.S)
open(Path(__file__).with_name('_js_check.js'), 'w', encoding='utf-8').write('\n'.join(m))

# main.py syntax
import ast
ast.parse(open(ROOT / 'src' / 'main.py', encoding='utf-8').read())
print('main.py ok')

# armas.json sanity
d = json.load(open(ROOT / 'src' / 'json' / 'armas.json', encoding='utf-8'))
print('armas:', len(d), '| primeira:', d[0]['nome'])
