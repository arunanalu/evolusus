"""Conversão DBC isolada para manter a licença e o mecanismo substituíveis."""
from pathlib import Path
import os

class ConverterUnavailable(RuntimeError): pass

def convert_dbc_to_csv(source: Path, destination: Path, encoding: str = "iso-8859-1") -> int:
    """Converte por pyreaddbc e promove o CSV somente após escrita completa.

    O extra é deliberadamente opcional: pyreaddbc é AGPL-3.0 e não é instalado
    sem decisão registrada. Retorna a contagem de registros.
    """
    try:
        from pyreaddbc.readdbc import dbc2dbf
        from dbfread import DBF
        import pandas as pd
    except ImportError as exc:
        raise ConverterUnavailable("instale o extra 'dbc' após aprovar AGPL-3.0") from exc
    dbf_temporary = destination.with_suffix(".dbf.part")
    temporary = destination.with_suffix(destination.suffix + ".part")
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        dbc2dbf(str(source), str(dbf_temporary))
        frame = pd.DataFrame(iter(DBF(str(dbf_temporary), encoding=encoding, char_decode_errors="replace")))
        if frame.empty: raise ValueError("conversao_dbc_sem_registros")
        frame.to_csv(temporary, index=False)
        os.replace(temporary, destination)
        return len(frame)
    finally:
        dbf_temporary.unlink(missing_ok=True)
