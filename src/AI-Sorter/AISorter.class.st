Class {
	#name : 'AISorter',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter',
	#package : 'AI-Sorter'
}

{ #category : 'sorting' }
AISorter >> ollamaReRank: candidateEntries context: completionContext [

| textUpToCaret api rankedResponse |
textUpToCaret := completionContext source
copyFrom: 1
to: completionContext position.

api := OllamaAPI new.
rankedResponse := api reRankCandidates: candidateEntries withContext: textUpToCaret.

^ rankedResponse ifEmpty: [ candidateEntries ]
]

{ #category : 'sorting' }
AISorter >> sortCompletionList: aCompletionList [
	"Use Ollama to re-rank the provided completion entries using the current
context. If there is no context or no entries, return the list unchanged."

	aCompletionList ifEmpty: [ ^ aCompletionList ].
	self context ifNil: [ ^ aCompletionList ].

	^ self ollamaReRank: aCompletionList context: self context
]
