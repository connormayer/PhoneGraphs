from collections import defaultdict
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats
import os
import csv

def build_result_arrays(avg_daland_results, model_results, key=None):
    out = [[],[]]

    for k in avg_daland_results:
        if not key or k == key:
            for ons in avg_daland_results[k]:
                out[0].append(avg_daland_results[k][ons])
                out[1].append(model_results[k][ons])
    return(np.array(out))

def evaluate(model_path, daland_path, plots=False):
    daland_file = open(daland_path, 'r')
    header = daland_file.readline()

    raw_daland_results = defaultdict(lambda: defaultdict(list))
    for line in daland_file:
        line = line.strip().split(',')
        ons = ' '.join(line[-2].split()[:2]).replace('"', '')
        att = line[1].replace('"', '')
        raw_daland_results[att][ons].append(float(line[2]))


    avg_daland_results = defaultdict(lambda: defaultdict(float))
    for k1 in raw_daland_results:
        for k2 in raw_daland_results[k1]:
            avg_daland_results[k1][k2] = np.mean(raw_daland_results[k1][k2])

    model_file = open(model_path, 'r')
    model_results = defaultdict(lambda: defaultdict(float))

    for line in model_file:

        line = line.strip().split('\t')
        # print(line)
        ons = ' '.join(line[0].strip().split(' ')[:2])
        score = float(line[1])
        for k in avg_daland_results:
            if ons in avg_daland_results[k]:
                model_results[k][ons] = score


    results = [['model_name', 'overall_t', 'overall_r', 'attested_t', 'attested_r', 'marginal_t', 'marginal_r', 'unattested_t', 'unattested_r']]
    name = os.path.split(model_path)[-1]
    row = [name]

    for key in [None, 'attested', 'marginal', 'unattested']:
        scores = build_result_arrays(avg_daland_results, model_results, key=key)

        r, p = stats.kendalltau(scores[0], scores[1])
        sr, sp = stats.pearsonr(scores[0], scores[1])
        row.append(r)
        row.append(sr)

    results.append(row)

    with open('../example/Outputs/{}.csv'.format(name), 'w') as f:
        writer = csv.writer(f)
        writer.writerows(results)

    return(r, p, sr, sp)

if __name__ == '__main__':
    import sys

    tau, taup, sr, sp = evaluate(sys.argv[1], sys.argv[2])

    print(f"\tTau: {tau:.4f} ({taup:.4f}). Pearson: {sr:.4f} ({sp:.4f})")

