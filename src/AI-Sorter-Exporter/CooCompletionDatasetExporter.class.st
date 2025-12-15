"
```
Available contexts
- #none:                 no surrounding information, emits context {}
- #completion:           receiver expression and the requested prefix
- #surroundingCompletion:source up to the call site plus the requested prefix (default fallback)
- #method:               full method source
- #classSignature:       class definition plus method signatures
- #class:                class definition plus full method sources
```


```
CooCompletionDatasetExporter
    exportOnPackage: 'NECompletion'
    heuristics: [ :builder | builder messageHeuristic ]
    to: 'completion-dataset.json'.
```

```
Metacello new
 baseline:'Seaside3';
 repository: 'github://SeasideSt/Seaside:master/repository';
 load
```

```
    Metacello new
        repository: 'github://pharo-spec/Spec';
        baseline: 'Spec2';
        onConflict: [ :e | e useIncoming ];
        onUpgrade: [ :e | e useIncoming ];
        ignoreImage;
        load

```


"
Class {
	#name : 'CooCompletionDatasetExporter',
	#superclass : 'CooStaticBenchmarksMessage',
	#instVars : [
		'entries',
		'contextStrategy',
		'methodContextCache',
		'classSignatureCache',
		'classFullContextCache'
	],
	#category : 'AI-Sorter-Exporter',
	#package : 'AI-Sorter-Exporter'
}

{ #category : 'as yet unclassified' }
CooCompletionDatasetExporter class >> exportOnPackage: aPackageOrName heuristics: aHeuristicsBlock to: aPathString [

	^ self
                exportOnPackages: { aPackageOrName }
                heuristics: aHeuristicsBlock
                to: aPathString
]

{ #category : 'as yet unclassified' }
CooCompletionDatasetExporter class >> exportOnPackages: aCollectionOfPackages heuristics: aHeuristicsBlock to: aPathString [

        | exporter |

        exporter := self new
                            builder: CoASTHeuristicsResultSetBuilder new;
                            yourself.

        aHeuristicsBlock ifNotNil: [ aHeuristicsBlock value: exporter builder ].
aCollectionOfPackages do: [ :packageOrName |
                | package |
                package := packageOrName isString
                                       ifTrue: [ PackageOrganizer default packageNamed: packageOrName ]
                                       ifFalse: [ packageOrName ].
                package ifNil: [ ^ self error: 'Package not found: ' , packageOrName printString ].
exporter scope: (CoBenchmarkPackage on: package).
                exporter run ].
exporter writeToFileNamed: aPathString.
        ^ exporter
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> benchCallsite: aMessageNode inMethod: aMethod atPosition: aPosition [

	| originalSelector position |
	originalSelector := aMessageNode selector.
	position := (aPosition respondsTo: #first)
		            ifTrue: [ aPosition first ]
		            ifFalse: [ aPosition ].

	2 to: (self maxPrefixSizeFor: originalSelector) do: [ :index |
			| prefix completion candidates context |
			prefix := self extractPrefixFrom: originalSelector at: index.
			aMessageNode selector: prefix.

			completion := self buildCompletionFor: aMessageNode atPosition: position.

			candidates := self fetchTopCandidatesFrom: completion usingPrefix: prefix.

			context := self contextFor: aMessageNode inMethod: aMethod atPosition: position withPrefix: prefix.

			self recordContext: context candidates: candidates correct: originalSelector ].

	aMessageNode selector: originalSelector
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> classFullContextFor: aMethod [

        | methodClass |
        methodClass := aMethod methodClass.
        methodClass ifNil: [ ^ self methodContextFor: aMethod ].

        ^ classFullContextCache
                  at: methodClass
                  ifAbsentPut: [ String
                                streamContents: [ :stream |
                                        stream nextPutAll: methodClass definition; cr; cr.
                                        stream nextPutAll: 'Instance methods:'; cr.
                                        methodClass methodDictionary values do: [ :compiled |
                                                stream nextPutAll: (self sourceForMethod: compiled); cr; cr ].
                                        stream nextPutAll: 'Class methods:'; cr.
                                        methodClass classSide methodDictionary values do: [ :compiled |
                                                stream nextPutAll: (self sourceForMethod: compiled); cr; cr ] ] ]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> classSignatureContextFor: aMethod [

        | methodClass |
        methodClass := aMethod methodClass.
        methodClass ifNil: [ ^ self methodContextFor: aMethod ].

        ^ classSignatureCache
                  at: methodClass
                  ifAbsentPut: [ String
                                streamContents: [ :stream |
                                        stream nextPutAll: methodClass definition; cr; cr.
                                        stream nextPutAll: 'Instance method signatures:'; cr.
                                        (methodClass selectors asSortedCollection) do: [ :selector |
                                                stream nextPutAll: selector; cr ].
                                        stream nextPutAll: 'Class method signatures:'; cr.
                                        (methodClass classSide selectors asSortedCollection) do: [ :selector |
                                                stream nextPutAll: selector; cr ] ] ]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> completionContextFor: aMessageNode withPrefix: prefix [

        | receiver source |
        receiver := aMessageNode receiver.
        source := aMessageNode methodNode source.

        receiver ifNil: [ ^ prefix ].

        ^ (self sourceForNode: receiver inMethodSource: source)
                  trimBoth , ' ' , prefix
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
CooCompletionDatasetExporter >> contextFor: aMessageNode inMethod: aMethod atPosition: aPosition withPrefix: prefix [

         ^ self contextStrategy
                caseOf: {
                        [ #none ] -> [ Dictionary new ].
                        [ #completion ] -> [ self completionContextFor: aMessageNode withPrefix: prefix ].
                        [ #method ] -> [ self methodContextFor: aMethod ].
                        [ #classSignature ] -> [ self classSignatureContextFor: aMethod ].
                        [ #class ] -> [ self classFullContextFor: aMethod ].
                        [ #surroundingCompletion ] -> [ self surroundingCompletionContextFor: aMessageNode atPosition: aPosition withPrefix: prefix ] }
                otherwise: [ self surroundingCompletionContextFor: aMessageNode atPosition: aPosition withPrefix: prefix ]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> contextStrategy [

        ^ contextStrategy
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> contextStrategy: aSymbol [

        contextStrategy := aSymbol ifNil: [ #completion ]
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

{ #category : 'initialization' }
CooCompletionDatasetExporter >> initialize [

        super initialize.
                entries := OrderedCollection new.
        contextStrategy := #completion.
        methodContextCache := Dictionary new.
        classSignatureCache := Dictionary new.
        classFullContextCache := Dictionary new
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> methodContextFor: aMethod [

        ^ methodContextCache
                  at: aMethod
                  ifAbsentPut: [ self sourceForMethod: aMethod ]
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
			node isMessage ifTrue: [ self benchCallsite: node inMethod: method atPosition: node keywordsIntervals first ] ]]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> sourceForMethod: aMethod [

        | source |
        source := (aMethod respondsTo: #sourceCode)
                             ifTrue: [ aMethod sourceCode ]
                             ifFalse: [ nil ].
        source ifNil: [ source := (aMethod respondsTo: #getSource)
                                             ifTrue: [ aMethod getSource ]
                                             ifFalse: [ nil ] ].
        ^ source ifNil: [ aMethod printString ]
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> sourceForNode: aNode inMethodSource: source [

        | interval |
        (aNode isNil or: [ source isNil ]) ifTrue: [ ^ '' ].

        interval := (aNode respondsTo: #sourceInterval)
                                 ifTrue: [ aNode sourceInterval ]
                                 ifFalse: [ nil ].
        (interval notNil and: [ interval size >= 2 ]) ifTrue: [
                ^ source copyFrom: interval first to: interval last ].

        ^ aNode printString
]

{ #category : 'accessing' }
CooCompletionDatasetExporter >> surroundingCompletionContextFor: aMessageNode atPosition: aPosition withPrefix: prefix [

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
