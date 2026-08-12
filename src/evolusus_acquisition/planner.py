from pathlib import PurePosixPath
from .models import Item

def load_config(path):
    import yaml
    with open(path, encoding="utf-8") as f: return yaml.safe_load(f)

def plan(config, source_names, year=2025, months=range(1,13)):
    selected = set(source_names) if source_names else set(config["sources"])
    for name, spec in config["sources"].items():
        if name not in selected: continue
        monthly = "{mm}" in spec["url_template"]
        for month in (months if monthly else [None]):
            values={"yy":str(year)[-2:], "mm":f"{month:02d}" if month else ""}
            url=spec["url_template"].format(**values)
            original_name=PurePosixPath(url.split("?")[0]).name or f"{name}.json"
            suffix=f"{year}{month:02d}" if month else str(year)
            yield Item(f"{name}:{suffix}",spec["system"],"RJ",year,month,url,spec["expected_format"],original_name)
