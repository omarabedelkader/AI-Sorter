# AI-Sorter

Install AI-Sorter

```st
Metacello new
  githubUser: 'omarabedelkader' project: 'AI-Sorter' commitish: 'main' path: 'src';
  baseline: 'AISorter';
  load
```

Run the sorter benchmarks over every package loaded in the image:

```st
CooStaticBenchmarksMessageSorter all.
CooStaticBenchmarksVariablesSorter all.
```

The generated `all-message.txt` and `all-variables.txt` reports start with totals for packages, classes, methods, sorter runs, completion attempts, and sorter failures.
