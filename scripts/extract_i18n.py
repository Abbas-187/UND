import re
import json
import os

dart_file = os.path.join('lib', 'l10n', 'app_localizations.dart')
out_dir = os.path.join('lib', 'l10n')

with open(dart_file, encoding='utf-8') as f:
    text = f.read()

# Extract the _localizedValues map block
map_block_match = re.search(r"_localizedValues\s*=\s*<String, Map<String, String>>\s*\{(.*)\};", text, re.S)
if not map_block_match:
    print('Could not find translation map')
    exit(1)
map_block = map_block_match.group(1)

# Find each locale map
for locale_match in re.finditer(r"'(?P<lang>\w+)':\s*\{(?P<entries>.*?)\}(,|$)", map_block, re.S):
    lang = locale_match.group('lang')
    entries_block = locale_match.group('entries')
    entries = re.findall(r"'(?P<key>[^']+)':\s*'(?P<val>(?:\\'|[^'])*)'", entries_block)
    data = {'@@locale': lang}
    for key, val in entries:
        data[key] = val.replace("\\'", "'")

    out_path = os.path.join(out_dir, f'app_{lang}.arb')
    with open(out_path, 'w', encoding='utf-8') as out_file:
        json.dump(data, out_file, ensure_ascii=False, indent=2)
    print(f'Wrote {out_path}')