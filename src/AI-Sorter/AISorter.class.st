Class {
	#name : 'AISorter',
	#superclass : 'Object',
	#category : 'AI-Sorter-Archive',
	#package : 'AI-Sorter',
	#tag : 'Archive'
}

{ #category : 'sorting' }
AISorter >> externalReRank: candidateEntries context: completionContext [
    | textUpToCaret api rankedResponse |

    textUpToCaret := completionContext source
        copyFrom: 1
        to: completionContext position.

    api := ExternalRerankerAPI new.
    rankedResponse := api
        reRankCandidates: candidateEntries
        withContext: textUpToCaret.

    ^ rankedResponse ifEmpty: [ candidateEntries ]
]

{ #category : 'sorting' }
AISorter >> sortCompletionList: aCompletionList [
    aCompletionList ifEmpty: [ ^ aCompletionList ].
    self context ifNil: [ ^ aCompletionList ].

    ^ self externalReRank: aCompletionList context: self context
]
