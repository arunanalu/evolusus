"""Prepara a recarga corrigida de CNES LT na camada Silver."""
import csv
import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("data/silver")
SOURCE = ROOT / "cnes_lt_data.csv"
LOG = ROOT / "export_log.csv"
TARGET = ROOT / "cnes_lt_data_corrigida.csv"
ORACLE_SAFE_TARGET = ROOT / "cnes_lt_data_oracle_safe.csv"
MANIFEST = ROOT / "cnes_lt_data_corrigida.manifest.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    if not SOURCE.is_file() or not LOG.is_file():
        raise FileNotFoundError("esperados cnes_lt_data.csv e export_log.csv em data/silver")
    log = LOG.read_text(encoding="utf-8-sig", errors="replace")
    error_columns = re.findall(r"error processing column ([A-Z0-9_]+)", log)
    if not error_columns or set(error_columns) != {"REGSAUDE"}:
        raise ValueError("o log não contém exclusivamente o erro esperado em REGSAUDE")

    temporary = TARGET.with_suffix(".csv.part")
    with SOURCE.open(encoding="utf-8-sig", newline="") as source, temporary.open("w", encoding="utf-8", newline="") as target:
        reader = csv.DictReader(source)
        if not reader.fieldnames or "REGSAUDE" not in reader.fieldnames:
            raise ValueError("coluna REGSAUDE não encontrada na origem")
        writer = csv.DictWriter(target, fieldnames=reader.fieldnames)
        writer.writeheader()
        rows = 0
        alphanumeric = 0
        for row in reader:
            value = row["REGSAUDE"]
            if any(char.isalpha() for char in value):
                alphanumeric += 1
            writer.writerow(row)
            rows += 1
    os.replace(temporary, TARGET)
    # A carga automática da Oracle inferiu NUMBER pelas primeiras linhas, que
    # não continham letras. Move uma linha existente (sem alterá-la) com código
    # alfanumérico para o início, forçando a inferência correta de VARCHAR2.
    with SOURCE.open(encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        all_rows = list(reader)
        sentinel_index = next((index for index, row in enumerate(all_rows)
                               if any(char.isalpha() for char in row["REGSAUDE"])), None)
        if sentinel_index is None:
            raise ValueError("não há REGSAUDE alfanumérica para validar a inferência Oracle")
        oracle_safe_rows = [all_rows[sentinel_index]] + all_rows[:sentinel_index] + all_rows[sentinel_index + 1:]
        safe_temporary = ORACLE_SAFE_TARGET.with_suffix(".csv.part")
        with safe_temporary.open("w", encoding="utf-8", newline="") as target:
            writer = csv.DictWriter(target, fieldnames=reader.fieldnames)
            writer.writeheader()
            writer.writerows(oracle_safe_rows)
        os.replace(safe_temporary, ORACLE_SAFE_TARGET)
    manifest = {
        "origem": str(SOURCE),
        "saida": str(TARGET),
        "saida_oracle_inferencia_automatica": str(ORACLE_SAFE_TARGET),
        "gerado_em_utc": datetime.now(timezone.utc).isoformat(),
        "registros": rows,
        "erros_log_regsaude": len(error_columns),
        "registros_regsaude_alfanumerica": alphanumeric,
        "correcao": "REGSAUDE deve ser carregada como VARCHAR2(10); valores preservados sem conversão numérica.",
        "sha256_origem": sha256(SOURCE),
        "sha256_saida": sha256(TARGET),
        "sha256_saida_oracle_inferencia_automatica": sha256(ORACLE_SAFE_TARGET),
        "sha256_log": sha256(LOG),
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{rows} registros -> {TARGET}")
    print(f"CSV para inferência Oracle -> {ORACLE_SAFE_TARGET}")
    print(f"{len(error_columns)} erros em REGSAUDE; {alphanumeric} registros alfanuméricos")


if __name__ == "__main__":
    main()
