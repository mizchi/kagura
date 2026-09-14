# Consumer benchmarks

複数の公開ライブラリを組み合わせて計測する、非公開の利用側 module。
`landscape/` は旧 `engine/landscape_bench`。`just bench-landscape` で実行する。
ライブラリ内の細粒度ベンチは引き続き各 package に置く。

所属 module の変更は計測条件の変更になる。旧所属の数値との比率を性能改善として報告しない。
配置変更後の探索用測定は `docs/performance/landscape-layout-baseline.txt`。
