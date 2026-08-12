import ftplib, hashlib, json, os, shutil, urllib.error, urllib.request
from datetime import datetime, timezone
from pathlib import Path
from .retry import classify
from .validator import validate
from .validator import ValidationError

def _utc(): return datetime.now(timezone.utc).isoformat()
def _retrieve(url, destination, user_agent, timeout):
    digest=hashlib.sha256(); size=0
    def write(block):
        nonlocal size
        out.write(block); digest.update(block); size += len(block)
    with open(destination,"xb") as out:
        if url.startswith("ftp://"):
            host_path=url[6:]; host, remote=host_path.split("/",1)
            ftp=ftplib.FTP(host, timeout=timeout); ftp.login(); ftp.set_pasv(True)
            try: ftp.retrbinary(f"RETR /{remote}", write, blocksize=1024*1024)
            finally: ftp.quit()
        else:
            request=urllib.request.Request(url,headers={"User-Agent":user_agent})
            with urllib.request.urlopen(request, timeout=timeout) as response:
                shutil.copyfileobj(response, _HashWriter(out,digest), length=1024*1024)
                size=out.tell()
    if size == 0: raise ValueError("arquivo_vazio")
    return digest.hexdigest(), size
class _HashWriter:
    def __init__(self,out,digest): self.out,self.digest=out,digest
    def write(self,b): self.digest.update(b); return self.out.write(b)

def acquire_one(item, state, root, runtime, retry):
    attempt=state.claim(item.key)
    if attempt is None: return "SKIPPED_VALID"
    part=root/"tmp"/f"{item.key.replace(':','_')}.part"; part.parent.mkdir(parents=True,exist_ok=True)
    part.unlink(missing_ok=True)
    try:
        sha,size=_retrieve(item.url,part,runtime["user_agent"],runtime["read_timeout_seconds"])
        checks=validate(item, part)
        final=root/"raw"/item.system.lower()/"RJ"/str(item.year)/(f"{item.month:02d}" if item.month else "annual")/sha/item.original_name
        final.parent.mkdir(parents=True,exist_ok=True); os.replace(part,final)
        manifest={"system":item.system,"uf":"RJ","year":item.year,"month":item.month,"url":item.url,"original_name":item.original_name,"downloaded_at_utc":_utc(),"size_bytes":size,"sha256":sha,"record_count_after_conversion":None,"converter_version":None,"status":"DESCONHECIDA","validation":checks}
        mp=root/"manifests"/item.system.lower()/"RJ"/str(item.year)/(f"{item.month:02d}" if item.month else "annual")/f"{sha}.json"; mp.parent.mkdir(parents=True,exist_ok=True); mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
        state.finish(item,sha,final,size); return "BAIXADO_VALIDO"
    except ValidationError as exc:
        state.fail(item.key,"QUARENTENA",str(exc)); return "QUARENTENA"
    except urllib.error.HTTPError as exc:
        decision=classify(exc.code,attempt,retry); state.fail(item.key,"FALHA_RETENTAVEL" if decision.retryable else "FALHA_FINAL",str(exc)); return "FALHA"
    except (OSError, urllib.error.URLError, ValueError) + ftplib.all_errors as exc:
        decision=classify(None,attempt,retry); state.fail(item.key,"FALHA_RETENTAVEL" if decision.retryable else "FALHA_FINAL",str(exc)); return "FALHA"
