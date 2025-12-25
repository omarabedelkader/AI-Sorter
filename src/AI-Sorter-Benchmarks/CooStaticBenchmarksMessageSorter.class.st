Class {
	#name : 'CooStaticBenchmarksMessageSorter',
	#superclass : 'CooStaticBenchmarksMessage',
	#category : 'AI-Sorter-Benchmarks',
	#package : 'AI-Sorter-Benchmarks'
}

{ #category : 'accessing' }
CooStaticBenchmarksMessageSorter class >> nec [
 <script>
^ self 
    runAllSortersOnPackage: NECEntry package
    exportReportTo: 'nec-sorter-benchmarks.txt'.
]
