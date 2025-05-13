import os
import re
from pathlib import Path

def fix_xci_outputdir(xci_dir="src/ip", target_base="../../project/project.gen/sources_1/ip"):
    for xci_path in Path(xci_dir).glob("*.xci"):

        content = xci_path.read_text(encoding='utf-8')

        ip_name = xci_path.stem

        pattern = r'(<spirit:configurableElementValue.*?RUNTIME_PARAM\.OUTPUTDIR.*?>)[^<]*(</spirit:configurableElementValue>)'
        replacement = fr'\1{target_base}/{ip_name}\2'

        new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

        xci_path.write_text(new_content, encoding='utf-8')
        print(f"Updated {xci_path.name} -> {target_base}/{ip_name}")

if __name__ == "__main__":
    fix_xci_outputdir()
