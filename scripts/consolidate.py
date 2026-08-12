"""Consolida CSVs técnicos por modalidade, preservando a rastreabilidade por linha."""
import argparse, csv, hashlib, os, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "src"))
from evolusus_acquisition.planner import load_config, plan
from evolusus_acquisition.state import State

TRACE = ["ANO_COMPETENCIA", "MES_COMPETENCIA", "SHA256_ORIGEM", "ARQUIVO_ORIGEM", "VERSAO_CONVERSOR", "LAYOUT_SHA256"]

def consolidate(root: Path, cfg: dict, source_name: str, year: int) -> Path:
    specs = list(plan(cfg, [source_name], year, range(1, 13)))
    if len(specs) != 12: raise ValueError(f"{source_name} não é uma fonte mensal com 12 competências")
    state = State(root / "state" / "acquisition.sqlite")
    rows = {r[0]: r for r in state.rows()}
    inputs=[]
    for item in specs:
        row=rows.get(item.key)
        if not row or row[1] != "CONVERTIDO_VALIDO" or not row[3]:
            raise ValueError(f"competência não convertida: {item.key}")
        path=root / "converted" / item.system.lower() / "RJ" / str(year) / f"{item.month:02d}" / row[3] / "dados.csv"
        if not path.is_file(): raise ValueError(f"CSV ausente: {path}")
        inputs.append((item,row[3],path))
    outdir=root / "consolidated" / source_name / "RJ" / str(year); outdir.mkdir(parents=True,exist_ok=True)
    part=outdir / "dados.csv.part"; final=outdir / "dados.csv"; provenance=outdir / "provenance.csv"
    schemas=[]; union=[]
    for _,_,path in inputs:
        with open(path,encoding="utf-8",newline="") as source:
            header=next(csv.reader(source), None)
        if not header: raise ValueError(f"CSV sem cabeçalho: {path}")
        schemas.append(header)
        for column in header:
            if column not in union: union.append(column)
    total=0
    with open(part,"w",encoding="utf-8",newline="") as target, open(provenance.with_suffix(".csv.part"),"w",encoding="utf-8",newline="") as proof:
        writer=csv.DictWriter(target,fieldnames=union+TRACE); writer.writeheader()
        proof_writer=csv.DictWriter(proof,fieldnames=["FONTE","ANO_COMPETENCIA","MES_COMPETENCIA","SHA256_ORIGEM","ARQUIVO_ORIGEM","LAYOUT_SHA256","REGISTROS"]); proof_writer.writeheader()
        for (item,sha,path), header in zip(inputs,schemas):
            with open(path,encoding="utf-8",newline="") as source:
                reader=csv.DictReader(source)
                if reader.fieldnames != header: raise ValueError(f"cabeçalho alterado durante leitura: {path}")
                layout_sha=hashlib.sha256("\x1f".join(header).encode()).hexdigest()
                count=0
                for row in reader:
                    row.update({"ANO_COMPETENCIA":year,"MES_COMPETENCIA":f"{item.month:02d}","SHA256_ORIGEM":sha,"ARQUIVO_ORIGEM":item.original_name,"VERSAO_CONVERSOR":"pyreaddbc==2.0.4","LAYOUT_SHA256":layout_sha})
                    writer.writerow(row); count += 1
                proof_writer.writerow({"FONTE":source_name,"ANO_COMPETENCIA":year,"MES_COMPETENCIA":f"{item.month:02d}","SHA256_ORIGEM":sha,"ARQUIVO_ORIGEM":item.original_name,"LAYOUT_SHA256":layout_sha,"REGISTROS":count})
                total += count
    os.replace(part,final); os.replace(provenance.with_suffix(".csv.part"),provenance)
    print(f"{source_name}: {total} registros -> {final}")
    return final

def main():
    parser=argparse.ArgumentParser(); parser.add_argument("--config",default="config/sources.rj-2025.yaml"); parser.add_argument("--source",required=True); parser.add_argument("--year",type=int,default=2025)
    args=parser.parse_args(); cfg=load_config(args.config); root=Path(cfg["runtime"]["output_root"])
    for source in args.source.split(","): consolidate(root,cfg,source,args.year)
if __name__ == "__main__": main()
