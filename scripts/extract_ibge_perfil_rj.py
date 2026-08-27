"""Extrai o perfil municipal complementar do IBGE para o piloto RJ/2025."""
import argparse
import csv
import gzip
import hashlib
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

BASE = "https://servicodados.ibge.gov.br/api/v3/agregados"
LOCALIDADES = "N6[N3[33]]"
EXPECTED_MUNICIPIOS = 92


def request_json(url: str) -> tuple[object, bytes]:
    request = Request(url, headers={"User-Agent": "EvoluSUS-academic-pilot/0.1"})
    with urlopen(request, timeout=90) as response:
        raw_response = response.read()
        raw = raw_response
        if response.headers.get("Content-Encoding", "").lower() == "gzip":
            raw = gzip.decompress(raw)
    return json.loads(raw), raw_response


def sidra_url(table: int, period: int, variables: str, classifications: str = "") -> str:
    query = f"localidades={LOCALIDADES}"
    if classifications:
        query += f"&classificacao={classifications}"
    return f"{BASE}/{table}/periodos/{period}/variaveis/{variables}?{query}"


def parse_value(value: str) -> int | float | None:
    if value in {"", "-", "...", "X", ".."}:
        return None
    number = float(value.replace(",", "."))
    return int(number) if number.is_integer() else number


def rows_from_response(payload: list) -> list[tuple[str, str, int | float | None]]:
    rows = []
    for variable in payload:
        for result in variable["resultados"]:
            for series in result["series"]:
                municipality = series["localidade"]
                for _, value in series["serie"].items():
                    rows.append((municipality["id"], municipality["nome"].removesuffix(" - RJ"), parse_value(value)))
    return rows


def only_value(payload: list) -> dict[str, tuple[str, int | float]]:
    result = {}
    for code, name, value in rows_from_response(payload):
        if code in result or value is None:
            raise ValueError(f"valor duplicado para município {code}")
        result[code] = (name, value)
    if len(result) != EXPECTED_MUNICIPIOS:
        raise ValueError(f"esperados {EXPECTED_MUNICIPIOS} municípios; recebidos {len(result)}")
    return result


def classification_ids(table: int, classification: int, level: int = 1) -> list[str]:
    metadata, _ = request_json(f"{BASE}/{table}/metadados")
    for item in metadata["classificacoes"]:
        if item["id"] == classification:
            return [str(category["id"]) for category in item["categorias"] if category["nivel"] == level]
    raise ValueError(f"classificação {classification} não encontrada na tabela {table}")


def add_dimension(data: dict, prefix: str, payload: list) -> None:
    for result in payload[0]["resultados"]:
        labels = [next(iter(item["categoria"].values())) for item in result["classificacoes"]]
        labels = [label for label in labels if label != "Total"]
        label = "_".join(labels).upper().replace(" ", "_").replace("Ç", "C").replace("Ã", "A").replace("Á", "A").replace("É", "E").replace("Í", "I").replace("Ó", "O").replace("Ú", "U").replace("-", "_")
        for series in result["series"]:
            value = parse_value(next(iter(series["serie"].values())))
            if value is not None:
                data[series["localidade"]["id"]][f"{prefix}_{label}"] = value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--year", type=int, default=2025)
    parser.add_argument("--output-root", type=Path, default=Path("data"))
    args = parser.parse_args()
    if args.year != 2025:
        parser.error("a fonte de população configurada está validada somente para 2025")

    calls: list[tuple[str, str, object, bytes]] = []
    def fetch(name: str, url: str) -> object:
        payload, raw = request_json(url)
        calls.append((name, url, payload, raw))
        time.sleep(0.25)
        return payload

    population = only_value(fetch("populacao_estimada_2025", sidra_url(6579, 2025, "9324")))
    data = {code: {"COD_MUNICIPIO": code, "NOME_MUNICIPIO": name, "ANO_ANALITICO": 2025,
                   "POPULACAO_ESTIMADA_2025": value, "ANO_REFERENCIA_PERFIL": 2022}
            for code, (name, value) in population.items()}

    race_ids = ",".join(classification_ids(9606, 86))
    sex_ids = ",".join(classification_ids(9606, 2))
    age_ids = ",".join(classification_ids(9606, 287))
    add_dimension(data, "POP_RACA_2022", fetch("raca_2022", sidra_url(9606, 2022, "93", f"86[{race_ids}]|2[6794]|287[100362]")))
    add_dimension(data, "POP_SEXO_2022", fetch("sexo_2022", sidra_url(9606, 2022, "93", f"86[95251]|2[{sex_ids}]|287[100362]")))
    add_dimension(data, "POP_IDADE_2022", fetch("idade_2022", sidra_url(9606, 2022, "93", f"86[95251]|2[6794]|287[{age_ids}]")))
    income = fetch("renda_2022", sidra_url(10295, 2022, "13431,13534", "2[6794]|86[95251]|58[95253]"))
    for variable in income:
        column = "RENDA_DOMICILIAR_PER_CAPITA_MEDIA_2022" if variable["id"] == "13431" else "RENDA_DOMICILIAR_PER_CAPITA_MEDIANA_2022"
        for code, _, value in rows_from_response([variable]):
            if value is not None:
                data[code][column] = value

    required = {"RENDA_DOMICILIAR_PER_CAPITA_MEDIA_2022", "RENDA_DOMICILIAR_PER_CAPITA_MEDIANA_2022"}
    if any(not required.issubset(row) for row in data.values()):
        raise ValueError("renda ausente para ao menos um município")
    output = args.output_root / "gold" / "ibge" / "rj" / str(args.year)
    output.mkdir(parents=True, exist_ok=True)
    target = output / f"ibge_perfil_municipal_rj_{args.year}.csv"
    fields = sorted({field for row in data.values() for field in row})
    temporary = target.with_suffix(".csv.part")
    with temporary.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()
        writer.writerows(data[code] for code in sorted(data))
    os.replace(temporary, target)

    manifest = {"sistema": "IBGE", "uf": "RJ", "ano_analitico": args.year, "situacao": "FINAL",
                "extraido_em_utc": datetime.now(timezone.utc).isoformat(), "arquivo_saida": str(target),
                "registros_saida": len(data), "perfil_referencia": 2022,
                "nota": "Somente a população total é estimativa municipal de 2025; perfil e renda são Censo 2022.",
                "objetos": [{"nome": name, "url": url, "sha256": hashlib.sha256(raw).hexdigest(), "bytes": len(raw)}
                            for name, url, _, raw in calls]}
    manifest_path = output / f"ibge_perfil_municipal_rj_{args.year}.manifest.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(data)} municípios -> {target}")
    print(f"manifesto -> {manifest_path}")


if __name__ == "__main__":
    main()
