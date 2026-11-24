"""Lance ./exe sur plusieurs grilles, vérifie l'ordre 2 et trace l'erreur."""
import re
import subprocess
import time

import matplotlib.pyplot as plt
import numpy as np

ns, errs = [64, 128, 256, 512, 1024], []
for n in ns:
    t0 = time.perf_counter()
    out = subprocess.run(["./exe", str(n)], capture_output=True, text=True, check=True).stdout
    dt = time.perf_counter() - t0
    errs.append(float(re.search(r"L2\s*:\s*(\S+)", out)[1]))
    print(f"| {n} | {errs[-1]:.3e} | {dt:.2f} |", flush=True)

ordre = -np.polyfit(np.log(ns), np.log(errs), 1)[0]
print(f"ordre observé : {ordre:.3f}")
assert abs(ordre - 2) < 0.05

h = 1 / np.array(ns)
plt.loglog(h, errs, "o-", label=f"erreur L2 (ordre {ordre:.2f})")
plt.loglog(h, errs[0] * (h / h[0]) ** 2, "k--", label="pente 2")
plt.xlabel("h")
plt.ylabel("erreur L2")
plt.legend()
plt.grid(which="both", alpha=0.3)
plt.savefig("convergence.png", dpi=150, bbox_inches="tight")
