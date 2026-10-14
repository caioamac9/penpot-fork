"""Remove da saída :analysis do clj-kondo as referências que se sobrepõem à
própria declaração (código gerado por macro), que derrubam o sonar-clojure 0.1.4."""
import json, sys

src, dst = sys.argv[1], sys.argv[2]
d = json.load(open(src, encoding="utf-8"))
a = d["analysis"]


def span(m):
    for k in (("name-row", "name-col", "name-end-row", "name-end-col"),
              ("row", "col", "end-row", "end-col")):
        if all(m.get(x) is not None for x in k):
            return tuple(m[x] for x in k)
    return None


def overlaps(s, t):
    return (s[0], s[1]) < (t[2], t[3]) and (t[0], t[1]) < (s[2], s[3])


decl = {}
for v in a.get("var-definitions", []):
    s = span(v)
    if s:
        decl.setdefault((v["filename"], v.get("ns"), v.get("name")), []).append(s)
ldecl = {}
for v in a.get("locals", []):
    s = span(v)
    if s:
        ldecl.setdefault((v["filename"], v.get("id")), []).append(s)


def keep(u, ds):
    s = span(u)
    return not (s and any(overlaps(s, t) for t in ds))


before = len(a.get("var-usages", [])) + len(a.get("local-usages", []))
a["var-usages"] = [u for u in a.get("var-usages", [])
                   if keep(u, decl.get((u["filename"], u.get("to"), u.get("name")), []))]
a["local-usages"] = [u for u in a.get("local-usages", [])
                     if keep(u, ldecl.get((u["filename"], u.get("id")), []))]
after = len(a["var-usages"]) + len(a["local-usages"])
json.dump(d, open(dst, "w", encoding="utf-8"))
print("referências removidas:", before - after)
