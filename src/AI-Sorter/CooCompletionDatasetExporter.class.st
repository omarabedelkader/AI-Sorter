"
```
CooCompletionDatasetExporter
    exportOnPackage: 'NECompletion'
    heuristics: [ :builder | builder messageHeuristic ]
    to: 'completion-dataset.json'.
```
"
Class {
	#name : 'CooCompletionDatasetExporter',
	#superclass : 'CooStaticBenchmarksMessage',
	#instVars : [
		'entries'
	],
	#category : 'AI-Sorter',
	#package : 'AI-Sorter'
}

{ #category : 'as yet unclassified' }
CooCompletionDatasetExporter class >> exportOnPackage: aPackageOrName heuristics: aHeuristicsBlock to: aPathString [

	| package exporter |
	package := aPackageOrName isString
		           ifTrue: [ PackageOrganizer default packageNamed: aPackageOrName ]
		           ifFalse: [ aPackageOrName ].
	package ifNil: [ ^ self error: 'Package not found: ' , aPackageOrName printString ].

	exporter := self new
		            scope: (CoBenchmarkPackage on: package);
		            builder: CoASTHeuristicsResultSetBuilder new;
		            yourself.

	aHeuristicsBlock ifNotNil: [ aHeuristicsBlock value: exporter builder ].

	exporter run.
	exporter writeToFileNamed: aPathString.
	^ exporter
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> benchCallsite: aMessageNode atPosition: aPosition [

        | originalSelector position |
        originalSelector := aMessageNode selector.
        position := (aPosition respondsTo: #first)
                           ifTrue: [ aPosition first ]
                           ifFalse: [ aPosition ].

        2 to: (self maxPrefixSizeFor: originalSelector) do: [ :index |
                | prefix completion candidates context |
                prefix := self extractPrefixFrom: originalSelector at: index.
                aMessageNode selector: prefix.

                completion := self
                                      buildCompletionFor: aMessageNode
                                      atPosition: position.

                candidates := self
                                      fetchTopCandidatesFrom: completion
                                      usingPrefix: prefix.

                context := self
                                   contextFor: aMessageNode
                                   atPosition: position
                                   withPrefix: prefix.

                self
                        recordContext: context
                        candidates: candidates
                        correct: originalSelector ].

        aMessageNode selector: originalSelector
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> contextFor: aMessageNode atPosition: aPosition withPrefix: prefix [

        | source position endIndex prefixContext |
        source := aMessageNode methodNode source.
        position := (aPosition respondsTo: #first)
                            ifTrue: [ aPosition first ]
                            ifFalse: [ aPosition ].
        position := position max: 1.
        position := position min: source size + 1.
        endIndex := position - 1.

        prefixContext := endIndex < 1
                                 ifTrue: [ '' ]
                                 ifFalse: [ source copyFrom: 1 to: endIndex ].
        ^ prefixContext , prefix
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> entries [
        ^ entries
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> entriesAsJsonString [

        ^ NeoJSONWriter toString: (entries collect: [ :entry |
                          Dictionary new
                                  at: 'context' put: (entry at: #context);
                                  at: 'candidates' put: (entry at: #candidates);
                                  at: 'correct' put: (entry at: #correct);
                                  yourself ])
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> initialize [

        super initialize.
        entries := OrderedCollection new
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> recordContext: context candidates: candidates correct: originalSelector [

        entries add: (Dictionary new
                                  at: #context put: context;
                                  at: #candidates put: (candidates collect: [ :each | each contents ]);
                                  at: #correct put: originalSelector;
                                  yourself)
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> run [

        scope methodsDo: [ :method |
                method parseTree nodesDo: [ :node |
                        node isMessage ifTrue: [
                                self benchCallsite: node atPosition: node keywordsIntervals first ] ]] 
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> writeToFileNamed: aString [

        | reference |
        reference := aString asFileReference.
        reference parent ensureCreateDirectory.
        reference writeStreamDo: [ :stream |
                stream
                        truncate;
                        nextPutAll: self entriesAsJsonString ]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> writeToFileReference: aFileReference [

        aFileReference writeStreamDo: [ :stream |
                stream
                        truncate;
                        nextPutAll: self entriesAsJsonString ]
]
