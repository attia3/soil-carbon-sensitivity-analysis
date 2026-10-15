# Original R script SHA-256 provenance

The following SHA-256 hashes identify the **unmodified** R scripts in the two user-supplied ZIP archives. The archived `.R` files in this repository contain those scripts with only the [safety header and `stop()` guard](../legacy/README.md) prepended.

| Original research script | Original bytes | Original SHA-256 |
| --- | ---: | --- |
| `Co_inertia3_12.R` | 9,729 | `8c74a930c4fee95ebd2d76ab0da6e968d01c94b55a49aaa71abc3ae4e45ab2d8` |
| `Co_inertia1.R` | 13,779 | `23ccc89505e2c772bf172edff2ba8e734403d746edf102f38e21701f5ba408ef` |
| `Senseanalysis5.R` | 12,266 | `2fa08254a64cea8d025811edde6244c077f8d074fafc7cc31a49f4a79412bddb` |
| `Senseanalysis6.R` | 11,687 | `ef8351f729a2a3b3617d4ca48b6378db66fe8e8cf27957ef0c475efdc1834e90` |
| `Senseanalysis7.R` | 12,246 | `eedf52bec48c74035dc15002d6cec5dba98da9b6729fe64e573b328d368ff045` |
| `Senseanalysis4.R` | 19,748 | `b848c5843815055873bdac4f1fc1a5ed2865bfdfdc308e440200bab5315fd90e` |
| `Sobol.R` | 8,369 | `4265e21e871a2bb53019d3576c8805c9dffc095eb5cfc917dcdb9b29f7e9f31f` |
| `Sobol2.R` | 7,376 | `5804d9487d7fa0c23c1e36223b7b9cb06d16be4ab19848ecfea5c57046a59162` |

**Important:** GitHub's code browser will show **different hashes** for guarded repository files, since the guard is an intentional modification. The table above allows independent verification against the original supplied ZIPs if those archives are retained privately.

The original archived scientific statements were transferred into GitHub byte-for-byte after UTF-8 decoding and re-encoding, and the resulting guarded file content was checked against the prepared source snapshot. A faithful source snapshot is not itself proof of successful model execution or numerical reproduction.
