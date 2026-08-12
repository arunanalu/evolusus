import csv
import importlib.util
import tempfile
import unittest
from pathlib import Path

spec=importlib.util.spec_from_file_location("consolidate",Path("scripts/consolidate.py")); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)

class ConsolidationTests(unittest.TestCase):
    def test_requires_twelve_converted_inputs_and_adds_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp); cfg={"sources":{"x":{"system":"CNES","url_template":"ftp://x/X{yy}{mm}.dbc","expected_format":"dbc"}}}
            from evolusus_acquisition.planner import plan
            from evolusus_acquisition.state import State
            state=State(root/"state"/"acquisition.sqlite")
            for item in plan(cfg,["x"],2025,range(1,13)):
                state.plan(item); sha=f"h{item.month}"; path=root/"converted"/"cnes"/"RJ"/"2025"/f"{item.month:02d}"/sha/"dados.csv"; path.parent.mkdir(parents=True); path.write_text("A\nvalor\n",encoding="utf-8")
                state.finish(item,sha,path, path.stat().st_size); state.converted(item.key)
            state.close(); output=module.consolidate(root,cfg,"x",2025)
            with open(output,encoding="utf-8",newline="") as f: rows=list(csv.DictReader(f))
            self.assertEqual(len(rows),12); self.assertEqual(rows[0]["MES_COMPETENCIA"],"01"); self.assertEqual(rows[-1]["MES_COMPETENCIA"],"12")

if __name__ == "__main__": unittest.main()
