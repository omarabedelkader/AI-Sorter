"
to allow this fetcher to work, please modify this code to this :
```
{ #category : 'visiting' }
CoASTHeuristicsResultSetBuilder >> visitMessageNode: aMessageNode [ 

    ""1) Build the normal fetcher chain from the messageHeuristic""
    | normalFetcher reRankFetcher resultSet |

    completionContext completionToken ifEmpty: [ ^ super visitMessageNode: aMessageNode ].
    normalFetcher := self messageHeuristic fetcherFor: aMessageNode inContext: completionContext.

    ""2) Decorate it with your Ollama ReRank""
    reRankFetcher := CoOllamaReRankFetcher new
        decoree: normalFetcher;
        completionContext: completionContext;
        yourself.

    ""3) Wrap that in a final CoResultSet""
    resultSet := CoResultSet fetcher: reRankFetcher withoutRepetition withNarrowHistory.

    ""4) Optionally set the filter to begin with whatever the user typed""
    resultSet filter: (
        CoBeginsWithFilter 
            caseSensitive: NECPreferences caseSensitive
            filterString: completionContext completionToken
    ).
    resultSet replaceFilterWith: (
        CoCaseSensitiveBeginsWithFilter 
            filterString: completionContext completionToken
    ).

    ^ resultSet
]
```
"
Class {
	#name : 'CoOllamaReRankFetcher',
	#superclass : 'CoFetcherDecorator',
	#instVars : [
		'completionContext'
	],
	#category : 'AI-Sorter',
	#package : 'AI-Sorter'
}

{ #category : 'accessing' }
CoOllamaReRankFetcher >> completionContext: aContext [ 

    completionContext := aContext
]

{ #category : 'accessing' }
CoOllamaReRankFetcher >> entriesDo: aBlock [ 

    | allResults reRanked |

    "1) Ask the wrapped fetcher (decoree) for all its results."
    allResults := OrderedCollection new.
    decoree entriesDo: [ :entry | allResults add: entry ].

    "2) Re-rank them via Ollama. 
       For example, pass the user’s typed token + the candidate list to Ollama."
    reRanked := self ollamaReRank: allResults.

    "3) Yield them in the new order."
    reRanked do: [ :each | aBlock value: each ]
]

{ #category : 'accessing' }
CoOllamaReRankFetcher >> ollamaReRank: candidateEntries [ 

    | textUpToCaret rankedResponse api |
    textUpToCaret := completionContext source
        copyFrom: 1
        to: completionContext position.

    api := OllamaAPI new.

    "You have to decide on a suitable prompt or call 
     that passes 'candidateEntries' to Ollama and returns an ordering.
     For instance, you might build a JSON with { 'prompt': 'Rank these: X,Y,Z' } 
     or something similar. Then parse the response as a new ordering."
    rankedResponse := api reRankCandidates: candidateEntries withContext: textUpToCaret.

    "Return them in the Ollama-chosen order. 
     'rankedResponse' might be an Array of entry indexes or the actual entries in new order."
    ^ rankedResponse
]
