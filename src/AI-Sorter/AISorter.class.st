Class {
	#name : 'AISorter',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter-new',
	#package : 'AI-Sorter',
	#tag : 'new'
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

self halt.
    aCompletionList ifEmpty: [ ^ aCompletionList ].

    ^ self externalReRank: aCompletionList context: self context
]
