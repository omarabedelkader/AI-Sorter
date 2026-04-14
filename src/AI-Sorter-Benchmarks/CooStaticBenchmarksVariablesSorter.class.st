"
managing variables for the bench
"
Class {
	#name : 'CooStaticBenchmarksVariablesSorter',
	#superclass : 'CooStaticBenchmarksVariables',
	#category : 'AI-Sorter-Benchmarks',
	#package : 'AI-Sorter-Benchmarks'
}

{ #category : 'accessing' }
CooStaticBenchmarksVariablesSorter class >> ast [

	<script>
	^ self runAllSortersOnPackage: OCASTCache package exportReportTo: 'ast.txt'
]

{ #category : 'accessing' }
CooStaticBenchmarksVariablesSorter class >> nec [

	<script>
	^ self runAllSortersOnPackage: NECEntry package exportReportTo: 'nec.txt'
]
