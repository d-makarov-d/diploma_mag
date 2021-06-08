import numpy as np
w = np.array([[[111., 112, 113],
               [121., 122, 123],
               [131., 132, 133],
               [141., 142, 143]],
              [[211., 212, 213],
               [221., 222, 223],
               [231., 232, 233],
               [241., 242, 243]]], dtype=np.float64)
b = np.zeros([2,3,4,5], dtype=np.float64)

with open("multidym.model", 'w') as f:
    out = "multidym\n"
    for w in (w, b):
        out += np.array2string(w, floatmode='maxprec')
        out += '\n'
    out = out[:-1]
    f.write(out)
