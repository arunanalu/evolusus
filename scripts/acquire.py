import argparse, json, sys
from datetime import datetime, timezone
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parents[1]/"src"))
from evolusus_acquisition.acquire import acquire_one
from evolusus_acquisition.converter import ConverterUnavailable, convert_dbc_to_csv
from evolusus_acquisition.planner import load_config, plan
from evolusus_acquisition.state import State

def main():
    p=argparse.ArgumentParser(); p.add_argument("command",choices=("plan","run","status")); p.add_argument("--config",default="config/sources.rj-2025.yaml"); p.add_argument("--source",default=""); p.add_argument("--months",default="01"); p.add_argument("--year",type=int,default=2025); p.add_argument("--allow-placeholder-contact",action="store_true"); p.add_argument("--convert-dbc",action="store_true")
    args=p.parse_args(); cfg=load_config(args.config); root=Path(cfg["runtime"]["output_root"]); state=State(root/"state"/"acquisition.sqlite")
    if args.command == "status":
        for r in state.rows():
            print("\t".join("" if x is None else str(x) for x in r))
        return
    names=[x for x in args.source.split(",") if x]
    months=[]
    for token in args.months.split(","):
        bounds=token.split("-",1)
        if len(bounds)==2: months.extend(range(int(bounds[0]),int(bounds[1])+1))
        else: months.append(int(token))
    if any(month < 1 or month > 12 for month in months): p.error("meses devem estar entre 01 e 12")
    items=list(plan(cfg,names,args.year,months))
    for item in items: state.plan(item)
    if args.command == "plan":
        for item in items: print(f"{item.key}\t{item.url}")
        return
    if "PREENCHER_ANTES_DE_RODAR" in cfg["runtime"]["user_agent"] and not args.allow_placeholder_contact:
        p.error("configure o contato do User-Agent ou passe --allow-placeholder-contact apenas em testes locais")
    for item in items:
        result=acquire_one(item,state,root,cfg["runtime"],cfg["retry"]); print(item.key, result)
        if result in {"BAIXADO_VALIDO", "SKIPPED_VALID"} and args.convert_dbc and item.expected_format == "dbc":
            row=next(r for r in state.rows() if r[0] == item.key)
            raw=next((root/"raw").rglob(f"{row[3]}/{item.original_name}"))
            try:
                target=root/"converted"/item.system.lower()/"RJ"/str(item.year)/(f"{item.month:02d}")/row[3]/"dados.csv"
                count=convert_dbc_to_csv(raw,target); state.converted(item.key)
                proof=target.parents[6]/"manifests"/item.system.lower()/"RJ"/str(item.year)/(f"{item.month:02d}")/f"{row[3]}.conversion.json"
                proof.parent.mkdir(parents=True,exist_ok=True)
                proof.write_text(json.dumps({"source_sha256":row[3],"converter":"pyreaddbc","converter_version":"2.0.4","output_format":"csv","record_count":count,"converted_at_utc":datetime.now(timezone.utc).isoformat()},indent=2),encoding="utf-8")
                print(item.key, "CONVERTIDO_VALIDO", count)
            except ConverterUnavailable as exc:
                print(item.key, "CONVERSAO_PENDENTE", exc)
if __name__ == "__main__": main()
