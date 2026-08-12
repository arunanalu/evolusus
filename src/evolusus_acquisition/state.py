import sqlite3
from datetime import datetime, timezone
from pathlib import Path

TERMINAL = {"BAIXADO_VALIDO", "CONVERTIDO_VALIDO", "QUARENTENA", "FALHA_FINAL"}
def now(): return datetime.now(timezone.utc).isoformat()

class State:
    def __init__(self, path: Path):
        path.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(path)
        self.db.execute("PRAGMA journal_mode=WAL")
        self.db.execute("PRAGMA busy_timeout=5000")
        self.db.execute("""CREATE TABLE IF NOT EXISTS acquisition_item (
          item_id TEXT PRIMARY KEY, source TEXT, uf TEXT, year INTEGER, month INTEGER, url TEXT,
          original_name TEXT, state TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0,
          active_sha256 TEXT, last_error TEXT, updated_at_utc TEXT NOT NULL)""")
        self.db.execute("""CREATE TABLE IF NOT EXISTS artifact_version (
          item_id TEXT, sha256 TEXT, path TEXT, size_bytes INTEGER, downloaded_at_utc TEXT,
          PRIMARY KEY(item_id, sha256))""")
        self.db.commit()
    def close(self):
        self.db.close()
    def plan(self, item):
        self.db.execute("""INSERT OR IGNORE INTO acquisition_item(item_id,source,uf,year,month,url,original_name,state,updated_at_utc)
        VALUES(?,?,?,?,?,?,?,?,?)""", (item.key,item.system,item.uf,item.year,item.month,item.url,item.original_name,"PENDENTE",now()))
        self.db.commit()
    def claim(self, key):
        row = self.db.execute("SELECT state,attempts FROM acquisition_item WHERE item_id=?", (key,)).fetchone()
        if not row or row[0] in TERMINAL: return None
        self.db.execute("UPDATE acquisition_item SET state='BAIXANDO',attempts=?,updated_at_utc=? WHERE item_id=?", (row[1]+1,now(),key)); self.db.commit()
        return row[1]+1
    def finish(self, item, sha, path, size):
        self.db.execute("INSERT OR IGNORE INTO artifact_version VALUES(?,?,?,?,?)", (item.key,sha,str(path),size,now()))
        self.db.execute("UPDATE acquisition_item SET state='BAIXADO_VALIDO',active_sha256=?,updated_at_utc=? WHERE item_id=?", (sha,now(),item.key)); self.db.commit()
    def converted(self, key):
        self.db.execute("UPDATE acquisition_item SET state='CONVERTIDO_VALIDO',updated_at_utc=? WHERE item_id=?", (now(),key)); self.db.commit()
    def fail(self, key, state, error):
        self.db.execute("UPDATE acquisition_item SET state=?,last_error=?,updated_at_utc=? WHERE item_id=?",(state,error,now(),key)); self.db.commit()
    def rows(self):
        return self.db.execute("SELECT item_id,state,attempts,active_sha256,last_error FROM acquisition_item ORDER BY item_id").fetchall()
