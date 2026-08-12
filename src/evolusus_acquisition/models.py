from dataclasses import asdict, dataclass

@dataclass(frozen=True)
class Item:
    key: str
    system: str
    uf: str
    year: int
    month: int | None
    url: str
    expected_format: str
    original_name: str

    def json(self):
        return asdict(self)
