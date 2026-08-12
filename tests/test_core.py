import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from evolusus_acquisition.acquire import acquire_one
from evolusus_acquisition.models import Item
from evolusus_acquisition.planner import plan
from evolusus_acquisition.retry import classify
from evolusus_acquisition.state import State

POLICY={"max_attempts":3,"base_delay_seconds":2,"max_delay_seconds":20,"jitter_ratio":0}
RUNTIME={"user_agent":"test","read_timeout_seconds":1}

class AcquisitionTests(unittest.TestCase):
    def test_retry_respects_retry_after_and_stops(self):
        self.assertEqual(classify(429,1,POLICY,11).delay_seconds,11)
        self.assertFalse(classify(404,1,POLICY).retryable)
        self.assertFalse(classify(503,3,POLICY).retryable)

    def test_planner_expands_monthly_and_annual_objects(self):
        cfg={"sources":{"a":{"system":"CNES","url_template":"ftp://x/A{yy}{mm}.dbc","expected_format":"dbc"},"b":{"system":"IBGE","url_template":"https://x/b","expected_format":"json"}}}
        self.assertEqual(len(list(plan(cfg,[],2025,range(1,13)))),13)

    def test_success_is_idempotent_and_writes_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp); state=State(root/"state.sqlite")
            item=Item("ibge_municipios:2025","IBGE","RJ",2025,None,"https://example.test/a","json","a.json")
            state.plan(item)
            def fake(url,path,ua,timeout):
                path.write_text(json.dumps([{"id":f"330{n:04d}"} for n in range(92)]),encoding="utf-8")
                import hashlib
                return hashlib.sha256(path.read_bytes()).hexdigest(),path.stat().st_size
            with patch("evolusus_acquisition.acquire._retrieve",fake):
                self.assertEqual(acquire_one(item,state,root,RUNTIME,POLICY),"BAIXADO_VALIDO")
                self.assertEqual(acquire_one(item,state,root,RUNTIME,POLICY),"SKIPPED_VALID")
            manifests=list((root/"manifests").rglob("*.json")); self.assertEqual(len(manifests),1)
            self.assertEqual(json.loads(manifests[0].read_text())["system"],"IBGE")
            state.close()

if __name__ == "__main__": unittest.main()
