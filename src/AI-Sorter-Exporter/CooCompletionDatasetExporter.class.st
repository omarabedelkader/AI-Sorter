"
To begin you can execute this:

```st 
CooCompletionDatasetExporter
    exportOnPackage: 'NECompletion'
    heuristics: [ :builder | builder messageHeuristic ]
	 context: #none
    to: 'completion-dataset.json'.
```


Available contexts
- #none:                 	no surrounding information, emits context {}
- #completion:           	receiver expression and the requested prefix
- #surroundingCompletion:	source up to the call site plus the requested prefix (default fallback)
- #method:               	full method source
- #classSignature:       	class definition plus method signatures
- #class:  


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
CooCompletionDatasetExporter class >> exportAllMessages [
	"Chnage the context if you want to channge which type of data you want. Refer to comments"
	<script>
	^ self
		  exportOnPackages:
			  #( 'Iceberg' 'Iceberg-ArchitecturalRules' 'Iceberg-Libgit' 'Iceberg-Libgit-Filetree' 'Iceberg-Libgit-Tonel'
			     'Iceberg-Memory' 'Iceberg-Metacello-Integration' 'Iceberg-Playground-Plugin-Gist' 'Iceberg-Plugin' 'Iceberg-Plugin-Github'
			     'Iceberg-Plugin-Metacello' 'Iceberg-Plugin-Migration' 'Iceberg-Plugin-Pharo' 'Iceberg-TipUI' 'Iceberg-TipUI-SnapShotBrowser'
			     'Iceberg-Plugin-Migration-Tests' 'Iceberg-Tests' 'Iceberg-Tests-MetacelloIntegration' 'Iceberg-TipUI-SnapshotBrowser-Tests'
			     'Iceberg-UI-Tests' 'Roassal' 'Roassal-Animation' 'Roassal-BaselineMap' 'Roassal-Builders' 'Roassal-Chart' 'Roassal-Chart-Examples'
			     'Roassal-Class-Examples' 'Roassal-Colors' 'Roassal-DSM' 'Roassal-Event' 'Roassal-Examples' 'Roassal-Experimental'
			     'Roassal-Exporters' 'Roassal-Exporters-Examples' 'Roassal-FlameGraph-Examples' 'Roassal-Inspector' 'Roassal-Interaction'
			     'Roassal-LayoutStudio' 'Roassal-Layouts' 'Roassal-Layouts-Util' 'Roassal-Legend' 'Roassal-Legend-Examples'
			     'Roassal-Menu' 'Roassal-Mondrian' 'Roassal-Pie' 'Roassal-Pie-Examples' 'Roassal-SVG' 'Roassal-SVG-Examples'
			     'Roassal-Shapes' 'Roassal-Spec' 'Roassal-Spec-Examples' 'Roassal-Spec-Morphic' 'Roassal-Sunburst' 'Roassal-Sunburst-Examples'
			     'Roassal-TreeMap' 'Roassal-TreeMap-Examples' 'Roassal-UML' 'Roassal-UML-Calypso' 'Roassal-UML-Examples'
			     'Roassal-Animation-Tests' 'Roassal-BaselineMap-Tests' 'Roassal-Chart-Tests' 'Roassal-Exporters-Tests'
			     'Roassal-Global-Tests' 'Roassal-Inspector-Tests' 'Roassal-Interaction-Tests' 'Roassal-LayoutStudio-Tests'
			     'Roassal-Layouts-Tests' 'Roassal-Shapes-Tests' 'Roassal-Spec-Tests' 'Roassal-SVG-Tests' 'Roassal-UML-Tests'
			     'Seaside-Ajaxifier-Core' 'Seaside-Canvas' 'Seaside-Component' 'Seaside-Continuation' 'Seaside-Core' 'Seaside-Development'
			     'Seaside-Email' 'Seaside-Environment' 'Seaside-Examples' 'Seaside-Flow' 'Seaside-JSON-Core' 'Seaside-Pharo-Canvas'
			     'Seaside-Pharo-Continuation' 'Seaside-Pharo-Core' 'Seaside-Pharo-Development' 'Seaside-Pharo-Email' 'Seaside-Pharo-Environment'
			     'Seaside-Pharo-Flow' 'Seaside-Pharo-JSON-Core' 'Seaside-Pharo-Tools-Web' 'Seaside-Pharo-Welcome' 'Seaside-REST-Core'
			     'Seaside-RenderLoop' 'Seaside-Session' 'Seaside-Tools-Core' 'Seaside-Tools-Web' 'Seaside-Welcome' 'Seaside-Widgets'
			     'Seaside-Zinc-Core' 'Seaside-Zinc-Pharo' 'Seaside-Tests-Canvas' 'Seaside-Tests-Component' 'Seaside-Tests-Core'
			     'Seaside-Tests-Environment' 'Seaside-Tests-Flow' 'Seaside-Tests-Functional' 'Seaside-Tests-Pharo-Canvas'
			     'Seaside-Tests-Pharo-Continuation' 'Seaside-Tests-Pharo-Core' 'Seaside-Tests-Pharo-Functional'
			     'Seaside-Tests-RenderLoop' 'Seaside-Tests-Session' 'Spec2-Adapters-Morphic' 'Spec2-Adapters-Morphic-ListView'
			     'Spec2-Adapters-Stub' 'Spec2-Code' 'Spec2-Code-Commands' 'Spec2-Code-Diff' 'Spec2-Code-Diff-Morphic'
			     'Spec2-Code-Morphic' 'Spec2-CommandLine' 'Spec2-Commander2' 'Spec2-Commands' 'Spec2-CommonWidgets' 'Spec2-Core'
			     'Spec2-Dialogs' 'Spec2-Examples' 'Spec2-Interactions' 'Spec2-Layout' 'Spec2-ListView' 'Spec2-Microdown' 'Spec2-Morphic'
			     'Spec2-Morphic-Examples' 'Spec2-Transmission' 'Spec2-Adapters-Morphic-Tests' 'Spec2-Backend-Tests' 'Spec2-Code-Backend-Tests'
			     'Spec2-Code-Diff-Tests' 'Spec2-Code-Tests' 'Spec2-Commander2-Tests' 'Spec2-Dialogs-Tests' 'Spec2-Morphic-Backend-Tests'
			     'Spec2-Morphic-Tests' 'Spec2-Tests' 'Moose-Blueprint-Invocations-Models' 'Moose-Blueprint-Models' 'Moose-Blueprint-Visualization-Models'
			     'Moose-Configuration' 'Moose-Core' 'Moose-Core-Generator' 'Moose-Importers' 'Moose-Query' 'Moose-Query-Extensions'
			     'Moose-SmalltalkImporter' 'MooseIDE-WelcomeBrowser' 'MooseIDE-Analysis' 'MooseIDE-AttributedText'
			     'MooseIDE-ButterflyMap' 'MooseIDE-ClassBlueprint' 'MooseIDE-CoUsageMap' 'MooseIDE-Core' 'MooseIDE-Core-Reporter'
			     'MooseIDE-CriticBrowser' 'MooseIDE-Dependency' 'MooseIDE-Duplication' 'MooseIDE-Export' 'MooseIDE-Famix' 'MooseIDE-LayerVisualization'
			     'MooseIDE-Meta' 'MooseIDE-NewTools' 'MooseIDE-QueriesBrowser' 'MooseIDE-QueriesDashboard' 'MooseIDE-Spotter'
			     'MooseIDE-Tagging' 'MooseIDE-Visualization' 'Moose-Blueprint-Models-Tests' 'Moose-Core-Tests' 'Moose-Core-Tests-Entities'
			     'Moose-Importers-Tests' 'Moose-Query-Test' 'Moose-SmalltalkImporter-Core-Tests' 'Moose-SmalltalkImporter-KGB-Tests'
			     'Moose-SmalltalkImporter-LAN-Tests' 'Moose-TestResources-KGB-P10InteractedReferee'
			     'Moose-TestResources-KGB-P11FullReferee' 'Moose-TestResources-KGB-P12FullReferencer'
			     'Moose-TestResources-KGB-P13FullReferencer' 'Moose-TestResources-KGB-P14FullReferee'
			     'Moose-TestResources-KGB-P1FullReferencer' 'Moose-TestResources-KGB-P2InteractedReferencerReferee'
			     'Moose-TestResources-KGB-P3InteractedReferencer' 'Moose-TestResources-KGB-P4FullInteracted'
			     'Moose-TestResources-KGB-P5FullReferee' 'Moose-TestResources-KGB-P6InteractedReferee'
			     'Moose-TestResources-KGB-P7ReferencerReferee' 'Moose-TestResources-KGB-P8FullReferencer'
			     'Moose-TestResources-KGB-P9FullReferencer' 'Moose-TestResources-KGB-PExtensions' 'Moose-TestResources-LAN'
			     'Moose-TestResources-LCOM' 'Moose-TestResources-PackageBlueprint-P1' 'Moose-TestResources-PackageBlueprint-P2'
			     'Moose-TestResources-PackageBlueprint-P3' 'Moose-TestResources-PackageBlueprint-P4'
			     'Moose-TestResources-Reference-Core' 'Moose-TestResources-Reference-External' 'Moose-TestResources-Reference-PackageOne'
			     'Moose-TestResources-Reference-PackageTwo' 'MooseIDE-ButterflyMap-Tests' 'MooseIDE-CoUsageMap-Tests'
			     'MooseIDE-CriticBrowser-Tests' 'MooseIDE-NewTools-Tests' 'MooseIDE-QueriesBrowser-Tests' 'MooseIDE-Spotter-Tests'
			     'MooseIDE-Tagging-Tests' 'MooseIDE-Tests' )
		  heuristics: [ :builder | builder messageHeuristic ]
		  context: #none
		  to: 'completion-dataset.json'
]

{ #category : 'as yet unclassified' }
CooCompletionDatasetExporter class >> exportOnPackages: aCollectionOfPackages heuristics: aHeuristicsBlock context: aContextStrategy to: aPathString [

| exporter |
exporter := self new
                            builder: CoASTHeuristicsResultSetBuilder new;
                            contextStrategy: aContextStrategy;
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
