import json
import gzip
from pathlib import Path

class ValidationError(ValueError): pass

def validate(item, path: Path) -> dict:
    if path.stat().st_size <= 0: raise ValidationError("arquivo_vazio")
    checks={"non_empty": True}
    if item.expected_format != "json": return checks
    raw=path.read_bytes()
    if raw[:2] == b"\x1f\x8b": raw=gzip.decompress(raw)
    try: body=json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError,json.JSONDecodeError) as exc: raise ValidationError("json_invalido") from exc
    checks["json_valid"]=True
    if item.key.startswith("ibge_municipios"):
        codes=[str(row.get("id","")) for row in body] if isinstance(body,list) else []
        if len(codes) != 92 or len(set(codes)) != 92 or any(len(c) != 7 or not c.isdigit() for c in codes):
            raise ValidationError("ibge_municipios_esperava_92_codigos_unicos_de_7_digitos")
        checks["municipalities_count"]=92
    if item.key.startswith("ibge_populacao"):
        results=body[0].get("resultados",[]) if isinstance(body,list) and body else []
        series=results[0].get("series",[]) if results else []
        if len(series) != 92: raise ValidationError("ibge_populacao_esperava_92_series")
        checks["population_series_count"]=92
    return checks
