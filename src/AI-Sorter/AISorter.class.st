Class {
	#name : 'AISorter',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter-new',
	#package : 'AI-Sorter',
	#tag : 'new'
}

{ #category : 'sorting' }
AISorter >> contextTextFrom: aCompletionContext [
	aCompletionContext ifNil: [ ^ '' ].

	(aCompletionContext respondsTo: #source)
		ifFalse: [ ^ '' ].

	(aCompletionContext respondsTo: #position)
		ifFalse: [ ^ '' ].

	^ [ 
		| src pos |
		src := aCompletionContext source.
		pos := aCompletionContext position.

		src ifNil: [ '' ]
			ifNotNil: [
				pos ifNil: [ src ]
					ifNotNil: [
						src copyFrom: 1 to: (pos min: src size) ] ] ]
		on: Error
		do: [ '' ]
]

{ #category : 'sorting' }
AISorter >> externalReRank: candidateEntries context: completionContext [
	| textUpToCaret api rankedResponse |

	textUpToCaret := ''.

	((completionContext notNil
		and: [ completionContext respondsTo: #source ])
		and: [ completionContext respondsTo: #position ]) ifTrue: [
			[ textUpToCaret := completionContext source
				copyFrom: 1
				to: (completionContext position min: completionContext source size) ]
				on: Error
				do: [ textUpToCaret := '' ] ].

	api := ExternalRerankerAPI new.
	rankedResponse := api
		reRankCandidates: candidateEntries
		withContext: textUpToCaret.

	^ rankedResponse ifEmpty: [ candidateEntries ]
]

{ #category : 'sorting' }
AISorter >> sortCompletionList: aCompletionList [
	aCompletionList ifEmpty: [ ^ aCompletionList ].
	^ self externalReRank: aCompletionList context: self context
]
