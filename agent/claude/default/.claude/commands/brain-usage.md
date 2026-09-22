---
description: Write the token/model/cost digest for this month into the brain's 50-Ops/Usage/
---

Run the usage digest and write it into the vault:

```bash
python .brain/usage.py --month $(date +%Y-%m)
```

Then show the user the Total section only — the per-day table is in the file, don't paste it back.

If they asked for something narrower, use `--days N`, `--projects`, or `--blocks` instead and
print to stdout without writing the file.

Note when reporting: the dollar figure is API-equivalent cost, not what a Pro subscription
charges. The number that actually matters is the **cache hit rate** — cache reads bill at 10%
of input, so a falling hit rate is the real cost signal.
