"
Runs a benchmark class over every package currently loaded in the image.
The runner keeps package failures isolated and writes a report with aggregate
package, class, method, sorter, and completion-attempt counts.
"
Class {
	#name : 'CooImageBenchmarkRunner',
	#superclass : 'Object',
	#instVars : [
		'benchmarkClass',
		'packages',
		'results',
		'stats',
		'failures'
	],
	#category : 'AI-Sorter-Benchmarks',
	#package : 'AI-Sorter-Benchmarks'
}

{ #category : 'running' }
CooImageBenchmarkRunner class >> imagePackages [

	^ PackageOrganizer default packages asSortedCollection: [ :a :b |
		  a name < b name ]
]

{ #category : 'running' }
CooImageBenchmarkRunner class >> run: aBenchmarkClass [

	^ self new
		  benchmarkClass: aBenchmarkClass;
		  run
]

{ #category : 'running' }
CooImageBenchmarkRunner class >> run: aBenchmarkClass exportReportTo: aFileReference [

	^ self new
		  benchmarkClass: aBenchmarkClass;
		  runAndExportReportTo: aFileReference
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> benchmarkClass [

	^ benchmarkClass
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> benchmarkClass: aClass [

	benchmarkClass := aClass
]

{ #category : 'private' }
CooImageBenchmarkRunner >> benchmarkRunCount [

	| total |
	total := 0.
	results valuesDo: [ :packageResults |
		total := total + packageResults size ].
	^ total
]

{ #category : 'private' }
CooImageBenchmarkRunner >> classForMethod: aCompiledMethod [

	| methodClass |
	(aCompiledMethod respondsTo: #methodClass) ifTrue: [
		methodClass := aCompiledMethod methodClass ].
	(methodClass isNil and: [ aCompiledMethod respondsTo: #origin ])
		ifTrue: [ methodClass := aCompiledMethod origin ].

	methodClass ifNil: [ ^ nil ].
	^ self instanceSideOf: methodClass
]

{ #category : 'private' }
CooImageBenchmarkRunner >> completionAttemptCount [

	| total |
	total := 0.
	results valuesDo: [ :packageResults |
		packageResults valuesDo: [ :benchmark |
			total := total + (self completionAttemptCountFor: benchmark) ] ].
	^ total
]

{ #category : 'private' }
CooImageBenchmarkRunner >> completionAttemptCountFor: aBenchmark [

	| total |
	total := 0.
	aBenchmark completionTimes valuesDo: [ :entry |
		total := total + entry second ].
	^ total
]

{ #category : 'private' }
CooImageBenchmarkRunner >> definedClassesForPackage: aPackage [

	(aPackage respondsTo: #definedClasses) ifTrue: [
		^ aPackage definedClasses ].
	(aPackage respondsTo: #classes) ifTrue: [ ^ aPackage classes ].
	(aPackage respondsTo: #definedClassNames) ifTrue: [
		^ aPackage definedClassNames ].
	^ #(  )
]

{ #category : 'private' }
CooImageBenchmarkRunner >> descriptionForError: anError [

	| description |
	description := [ anError description ]
		               on: Error
		               do: [ nil ].
	^ description ifNil: [ anError printString ]
]

{ #category : 'private' }
CooImageBenchmarkRunner >> exportReportTo: aFileReference [

	| output |
	output := aFileReference asFileReference.
	output ensureCreateFile.
	output writeStreamDo: [ :stream | self writeReportOn: stream ]
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> failures [

	^ failures
]

{ #category : 'initialization' }
CooImageBenchmarkRunner >> initialize [

	super initialize.
	packages := self class imagePackages.
	results := Dictionary new.
	stats := OrderedCollection new.
	failures := OrderedCollection new
]

{ #category : 'private' }
CooImageBenchmarkRunner >> instanceSideOf: aClass [

	((aClass respondsTo: #isMeta) and: [ aClass isMeta ]) ifTrue: [
		(aClass respondsTo: #instanceSide) ifTrue: [ ^ aClass instanceSide ].
		(aClass respondsTo: #theNonMetaClass) ifTrue: [
			^ aClass theNonMetaClass ] ].
	^ aClass
]

{ #category : 'private' }
CooImageBenchmarkRunner >> packageNameFor: aPackage [

	(aPackage respondsTo: #name) ifTrue: [ ^ aPackage name ].
	(aPackage respondsTo: #packageName) ifTrue: [ ^ aPackage packageName ].
	^ aPackage asString
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> packages [

	^ packages
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> packages: aCollection [

	packages := aCollection
]

{ #category : 'private' }
CooImageBenchmarkRunner >> packageStatsFor: aPackage [

	| classes methodCount |
	classes := Set new.
	methodCount := 0.

	(CoBenchmarkPackage on: aPackage) methodsDo: [ :method |
		methodCount := methodCount + 1.
		(self classForMethod: method) ifNotNil: [ :methodClass |
			classes add: methodClass ] ].

	classes isEmpty ifTrue: [
		classes addAll: (self definedClassesForPackage: aPackage) ].

	^ Dictionary new
		  at: #package put: aPackage;
		  at: #packageName put: (self packageNameFor: aPackage);
		  at: #classes put: classes size;
		  at: #methods put: methodCount;
		  yourself
]

{ #category : 'private' }
CooImageBenchmarkRunner >> packageStatsFor: aPackage statsError: anError [

	^ Dictionary new
		  at: #package put: aPackage;
		  at: #packageName put: (self packageNameFor: aPackage);
		  at: #classes put: 0;
		  at: #methods put: 0;
		  at: #statsError put: (self descriptionForError: anError);
		  yourself
]

{ #category : 'private' }
CooImageBenchmarkRunner >> recordFailureForPackage: packageName sorter: sorterSymbol error: anError [

	failures add: (Dictionary new
			 at: #packageName put: packageName;
			 at: #sorter put: sorterSymbol;
			 at: #error put: (self descriptionForError: anError);
			 yourself)
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> results [

	^ results
]

{ #category : 'running' }
CooImageBenchmarkRunner >> run [

	benchmarkClass ifNil: [ self error: 'A benchmark class must be set' ].

	results := Dictionary new.
	stats := OrderedCollection new.
	failures := OrderedCollection new.

	packages do: [ :package | self runPackage: package ].
	^ self summary
]

{ #category : 'running' }
CooImageBenchmarkRunner >> runAndExportReportTo: aFileReference [

	| summary |
	summary := self run.
	self exportReportTo: aFileReference.
	^ summary
]

{ #category : 'private' }
CooImageBenchmarkRunner >> runPackage: aPackage [

	| packageName packageStats packageResults failureCountBefore sorterFailures |
	packageName := self packageNameFor: aPackage.
	packageStats := [
		                self packageStatsFor: aPackage ]
		                on: Error
		                do: [ :error |
			                self packageStatsFor: aPackage statsError: error ].
	packageStats at: #status put: #pending.
	stats add: packageStats.

	failureCountBefore := failures size.
	packageResults := self runSortersOnPackage: aPackage named: packageName.
	sorterFailures := failures size - failureCountBefore.
	packageStats at: #sorterFailures put: sorterFailures.

	packageResults
		ifEmpty: [ packageStats at: #status put: #failed ]
		ifNotEmpty: [
			results at: packageName put: packageResults.
			packageStats
				at: #status
				put: (sorterFailures = 0 ifTrue: [ #completed ] ifFalse: [ #partial ]) ]
]

{ #category : 'private' }
CooImageBenchmarkRunner >> runSortersOnPackage: aPackage named: packageName [

	| packageResults |
	packageResults := Dictionary new.
	benchmarkClass sorterClasses do: [ :sorterSymbol |
		[
		| sorterClass benchmark |
		sorterClass := Smalltalk globals at: sorterSymbol.
		benchmark := benchmarkClass new
			             scope: (CoBenchmarkPackage on: aPackage);
			             builder: (CooGlobalSorterResultSetBuilder new
					              sorterClass: sorterClass;
					              yourself);
			             yourself.
		benchmark run.
		packageResults at: sorterSymbol put: benchmark ]
			on: Error
			do: [ :error |
				self
					recordFailureForPackage: packageName
					sorter: sorterSymbol
					error: error ] ].
	^ packageResults
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> stats [

	^ stats
]

{ #category : 'private' }
CooImageBenchmarkRunner >> sum: aKey in: aCollection [

	^ aCollection
		  inject: 0
		  into: [ :sum :each | sum + (each at: aKey ifAbsent: [ 0 ]) ]
]

{ #category : 'accessing' }
CooImageBenchmarkRunner >> summary [

	| benchmarked failed summary |
	benchmarked := stats select: [ :each |
		               #( completed partial ) includes:
			               (each at: #status ifAbsent: [ #unknown ]) ].
	failed := stats select: [ :each |
		          (each at: #status ifAbsent: [ #unknown ]) = #failed ].
	summary := Dictionary new.
	summary
		at: #benchmarkClass put: benchmarkClass;
		at: #packagesFound put: packages size;
		at: #packagesBenchmarked put: benchmarked size;
		at: #packagesFailed put: failed size;
		at: #classesBenchmarked put: (self sum: #classes in: benchmarked);
		at: #methodsBenchmarked put: (self sum: #methods in: benchmarked);
		at: #sorterClasses put: benchmarkClass sorterClasses;
		at: #benchmarkRuns put: self benchmarkRunCount;
		at: #sorterFailures put: failures size;
		at: #completionAttempts put: self completionAttemptCount;
		at: #stats put: stats;
		at: #failures put: failures;
		at: #results put: results;
		yourself.
	^ summary
]

{ #category : 'private' }
CooImageBenchmarkRunner >> writeDetailedResultsOn: aStream [

	aStream
		cr;
		nextPutAll: '### Detailed benchmark results ###';
		cr;
		cr.

	results keys asSortedCollection do: [ :packageName |
		| packageResults |
		packageResults := results at: packageName.
		aStream
			nextPutAll: '## ';
			nextPutAll: packageName;
			nextPutAll: ' ##';
			cr;
			cr.

		packageResults keys asSortedCollection do: [ :sorterSymbol |
			| benchmark |
			benchmark := packageResults at: sorterSymbol.
			aStream
				nextPutAll: '### ';
				nextPutAll: sorterSymbol asString;
				nextPutAll: ' ###';
				cr;
				cr;
				nextPutAll: benchmark textReport;
				cr;
				cr ] ]
]

{ #category : 'private' }
CooImageBenchmarkRunner >> writeFailuresOn: aStream [

	failures ifEmpty: [ ^ self ].

	aStream
		cr;
		nextPutAll: 'Failures';
		cr;
		nextPutAll: 'Package | Sorter | Error';
		cr.

	failures do: [ :failure |
		aStream
			nextPutAll: (failure at: #packageName);
			nextPutAll: ' | ';
			nextPutAll: (failure at: #sorter) asString;
			nextPutAll: ' | ';
			nextPutAll: (failure at: #error);
			cr ]
]

{ #category : 'private' }
CooImageBenchmarkRunner >> writePackageStatsOn: aStream [

	aStream
		cr;
		nextPutAll: 'Package stats';
		cr;
		nextPutAll: 'Package | Status | Classes | Methods | Note';
		cr.

	stats do: [ :each |
		| note |
		note := each
			        at: #error
			        ifAbsent: [
			        each at: #statsError ifAbsent: [ '' ] ].
		(each at: #sorterFailures ifAbsent: [ 0 ]) > 0 ifTrue: [
			note := note , (note isEmpty ifTrue: [ '' ] ifFalse: [ '; ' ])
			        , (each at: #sorterFailures) asString
			        , ' sorter failure(s)' ].
		aStream
			nextPutAll: (each at: #packageName);
			nextPutAll: ' | ';
			nextPutAll: (each at: #status ifAbsent: [ #unknown ]) asString;
			nextPutAll: ' | ';
			nextPutAll: (each at: #classes ifAbsent: [ 0 ]) asString;
			nextPutAll: ' | ';
			nextPutAll: (each at: #methods ifAbsent: [ 0 ]) asString;
			nextPutAll: ' | ';
			nextPutAll: note;
			cr ]
]

{ #category : 'private' }
CooImageBenchmarkRunner >> writeReportOn: aStream [

	self
		writeSummary: self summary on: aStream;
		writePackageStatsOn: aStream;
		writeFailuresOn: aStream;
		writeDetailedResultsOn: aStream
]

{ #category : 'private' }
CooImageBenchmarkRunner >> writeSummary: aSummary on: aStream [

	aStream
		nextPutAll: '### Image benchmark summary ###';
		cr;
		cr;
		nextPutAll: 'Benchmark: ';
		nextPutAll: benchmarkClass name;
		cr;
		nextPutAll: 'Packages found: ';
		nextPutAll: (aSummary at: #packagesFound) asString;
		cr;
		nextPutAll: 'Packages benchmarked: ';
		nextPutAll: (aSummary at: #packagesBenchmarked) asString;
		cr;
		nextPutAll: 'Packages failed: ';
		nextPutAll: (aSummary at: #packagesFailed) asString;
		cr;
		nextPutAll: 'Classes benchmarked: ';
		nextPutAll: (aSummary at: #classesBenchmarked) asString;
		cr;
		nextPutAll: 'Methods benchmarked: ';
		nextPutAll: (aSummary at: #methodsBenchmarked) asString;
		cr;
		nextPutAll: 'Sorters: ';
		nextPutAll:
			((benchmarkClass sorterClasses collect: [ :each | each asString ])
				 joinUsing: ', ');
		cr;
		nextPutAll: 'Benchmark runs: ';
		nextPutAll: (aSummary at: #benchmarkRuns) asString;
		cr;
		nextPutAll: 'Sorter failures: ';
		nextPutAll: (aSummary at: #sorterFailures) asString;
		cr;
		nextPutAll: 'Completion attempts: ';
		nextPutAll: (aSummary at: #completionAttempts) asString;
		cr
]
