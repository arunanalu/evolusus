"""Gera CSV seguro e manifesto para a recarga Oracle da CNES PF."""
import csv
import hashlib
import json
import os
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("data/consolidated/cnes_pf/RJ/2025")
SOURCE = ROOT / "cnes_pf_data.csv"
SUMMARY = ROOT / "ERROR_SUMMARY_CNES_PF_DATA_2_20260826.CSV"
TARGET = ROOT / "cnes_pf_data_corrigida.csv"
MANIFEST = ROOT / "cnes_pf_data_corrigida.manifest.json"
ERROR_COLUMNS = ("CBO", "CBOUNICO", "CONSELHO")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for block in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def contains_letter(value: str) -> bool:
    return any(character.isalpha() for character in value)


def main() -> None:
    if not SOURCE.is_file() or not SUMMARY.is_file():
        raise FileNotFoundError("esperados cnes_pf_data.csv e ERROR_SUMMARY_CNES_PF_DATA_2_20260826.CSV")
    summary = SUMMARY.read_text(encoding="utf-8-sig", errors="replace")
    if any(column not in summary for column in ERROR_COLUMNS):
        raise ValueError("o resumo não contém todas as colunas esperadas: CBO, CBOUNICO e CONSELHO")

    sentinels: dict[str, tuple[int, dict[str, str]]] = {}
    with SOURCE.open(encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        if not reader.fieldnames or any(column not in reader.fieldnames for column in ERROR_COLUMNS):
            raise ValueError("colunas de correção ausentes na origem")
        fields = reader.fieldnames
        for row_number, row in enumerate(reader, start=1):
            for column in ERROR_COLUMNS:
                if column not in sentinels and contains_letter(row[column]):
                    sentinels[column] = (row_number, row)
            if len(sentinels) == len(ERROR_COLUMNS):
                break
    if len(sentinels) != len(ERROR_COLUMNS):
        missing = set(ERROR_COLUMNS) - set(sentinels)
        raise ValueError(f"sem valor alfanumérico para: {sorted(missing)}")

    selected_numbers: list[int] = []
    selected_rows: list[dict[str, str]] = []
    for column in ERROR_COLUMNS:
        row_number, row = sentinels[column]
        if row_number not in selected_numbers:
            selected_numbers.append(row_number)
            selected_rows.append(row)

    temporary = TARGET.with_suffix(".csv.part")
    rows = 0
    with SOURCE.open(encoding="utf-8-sig", newline="") as source, temporary.open("w", encoding="utf-8", newline="") as target:
        reader = csv.DictReader(source)
        writer = csv.DictWriter(target, fieldnames=fields)
        writer.writeheader()
        writer.writerows(selected_rows)
        for row_number, row in enumerate(reader, start=1):
            if row_number not in selected_numbers:
                writer.writerow(row)
            rows += 1
    os.replace(temporary, TARGET)
    manifest = {
        "origem": str(SOURCE), "saida": str(TARGET), "gerado_em_utc": datetime.now(timezone.utc).isoformat(),
        "registros": rows, "correcao": {column: "VARCHAR2(20)" for column in ERROR_COLUMNS},
        "linhas_reposicionadas": {column: {"linha_origem": number, "valor": row[column]}
                                for column, (number, row) in sentinels.items()},
        "sha256_origem": sha256(SOURCE), "sha256_saida": sha256(TARGET), "sha256_resumo_erro": sha256(SUMMARY),
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{rows} registros -> {TARGET}")
    print("primeiras linhas preparadas para inferência textual: " + ", ".join(ERROR_COLUMNS))


if __name__ == "__main__":
    main()
