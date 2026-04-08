Class {
	#name : 'CooGlobalSorterResultSetBuilder',
	#superclass : 'CoASTResultSetBuilder',
	#instVars : [
		'sorterClass'
	],
	#category : 'AI-Sorter-Benchmarks',
	#package : 'AI-Sorter-Benchmarks'
}

{ #category : 'API - building' }
CooGlobalSorterResultSetBuilder >> parseNode [

	| aNewNode |
	aNewNode := super parseNode.
	TypingVisitor new visitNode: aNewNode methodNode.
	^ aNewNode
]

{ #category : 'API - building' }
CooGlobalSorterResultSetBuilder >> sorterClass [

	^ sorterClass ifNil: [ completionContext class sorterClass ]
]

{ #category : 'API - building' }
CooGlobalSorterResultSetBuilder >> sorterClass: anObject [

	sorterClass := anObject
]

{ #category : 'visiting' }
CooGlobalSorterResultSetBuilder >> visitNode: aNode [

	| fetcher entries |
	entries := aNode completionEntries: completionContext position.
	"we should probably be able to remove all the implementations of completionEntries:"
	fetcher := CoCollectionFetcher onCollection: entries.

	^ self configureFetcher: fetcher forNode: aNode
]
