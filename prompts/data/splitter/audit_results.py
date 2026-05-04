#!/usr/bin/env python3
"""
audit_results.py — Run locally after downloading results from vast.ai.

Usage:
    python3 prompts/data/splitter/audit_results.py \
        --report   prompts/data/split_report.json \
        --wav_dir  assets/vocab/audio

Prints a summary and lists any FAIL / duration-outlier clips.
"""

import argparse
import json
import os
import subprocess
import sys


def wav_duration(path):
    try:
        r = subprocess.run(
            ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
            capture_output=True, text=True, check=True,
        )
        return float(json.loads(r.stdout)['format']['duration'])
    except Exception:
        return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--report',  default='prompts/data/split_report.json')
    parser.add_argument('--wav_dir', default='assets/vocab/audio')
    args = parser.parse_args()

    if not os.path.exists(args.report):
        sys.exit(f'Report not found: {args.report}')

    report = json.load(open(args.report, encoding='utf-8'))
    total  = len(report)

    # Status counts
    passed = [e for e in report if e['status'] == 'PASS']
    warned = [e for e in report if e['status'] == 'WARN']
    failed = [e for e in report if e['status'] == 'FAIL']
    mms    = [e for e in report if e['fa_method'] == 'mms_fa']
    rough  = [e for e in report if e['fa_method'] == 'whisper_rough']

    # Check files on disk
    missing = []
    dur_outliers = []
    for e in report:
        path = os.path.join(args.wav_dir, e['out_path'])
        if not os.path.exists(path):
            missing.append(e['out_path'])
            continue
        dur = wav_duration(path)
        if dur is None or dur < 0.25 or dur > 8.5:
            dur_outliers.append((e['out_path'], dur, e.get('dur', '?')))

    # Expected total: 1000 (500 words × 2 examples)
    print(f'{"─"*55}')
    print(f'Report entries : {total:>5}   (expected 1000)')
    print(f'  PASS         : {len(passed):>5}')
    print(f'  WARN         : {len(warned):>5}')
    print(f'  FAIL         : {len(failed):>5}')
    print(f'  mms_fa       : {len(mms):>5}')
    print(f'  whisper_rough: {len(rough):>5}')
    print(f'Files missing  : {len(missing):>5}')
    print(f'Duration outliers (<0.25s or >8.5s): {len(dur_outliers)}')
    print(f'{"─"*55}')

    if missing:
        print('\nMissing files:')
        for f in missing[:20]:
            print(f'  {f}')
        if len(missing) > 20:
            print(f'  … and {len(missing)-20} more')

    if dur_outliers:
        print('\nDuration outliers:')
        for f, actual_dur, reported_dur in dur_outliers:
            d = f'{actual_dur:.2f}s' if actual_dur is not None else 'ERR'
            print(f'  {f}  actual={d}  reported={reported_dur}s')

    if failed:
        print('\nFAIL entries (CER > 0.40):')
        for e in failed:
            print(f"  w_{e['word_num']:04d}{e['ab']}  CER={e['cer']:.2f}"
                  f"  expected: {e['expected'][:30]!r}")
            print(f"           got:      {e['transcript'][:30]!r}")

    if warned:
        print(f'\nWARN entries ({len(warned)} total, CER 0.20–0.40):')
        for e in warned[:10]:
            print(f"  w_{e['word_num']:04d}{e['ab']}  CER={e['cer']:.2f}"
                  f"  {e['expected'][:25]!r}")
        if len(warned) > 10:
            print(f'  … and {len(warned)-10} more')

    ok = len(passed) >= 970 and len(missing) == 0 and len(dur_outliers) == 0
    print(f'\n{"✓ All good" if ok else "✗ Issues found — review above"}')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
