"
```st
| client payload response json scores |

client := ZnClient new
    url: 'http://127.0.0.1:8000/rank';
    method: #POST.

payload := Dictionary new
    at: 'context' put: 'Ordered';
    at: 'candidates' put: #(
        'OrderedIdentityDictionaryTest'
        'OrderedDictionary'
        'OrderedCollection'
        'OrderedDictionaryTest'
    );
    yourself.

client entity: (
    ZnEntity
        with: (NeoJSONWriter toString: payload)
        type: ZnMimeType applicationJson
).

response := client execute.

json := NeoJSONReader fromString: response contents.
scores := json at: 'scores'.

```
"
Class {
	#name : 'CatBoostSorter',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter-Sorter',
	#package : 'AI-Sorter',
	#tag : 'Sorter'
}

{ #category : 'as yet unclassified' }
CatBoostSorter >> modelName [
    self subclassResponsibility
]

{ #category : 'as yet unclassified' }
CatBoostSorter >> sortCompletionList: anOrderedCollection [

    | ctx candidates payload client response json rankedNames indexByName rankedEntries |

    "Trivial cases"
    anOrderedCollection size <= 1 ifTrue: [ ^ anOrderedCollection ].

    "Context"
    ctx := self context.
    ctx isString ifFalse: [ ctx := '' ].

    "Extract candidate strings"
    candidates := anOrderedCollection collect: [ :each | each contents ].

    "Build payload"
    payload := Dictionary new
        at: 'context' put: ctx;
        at: 'candidates' put: candidates;
        at: 'model' put: self modelName;
        yourself.

    "Call ranker"
    [
        client := ZnClient new
            url: 'http://127.0.0.1:8000/rank';
            method: #POST;
            timeout: 1;
            yourself.

        client entity: (
            ZnEntity
                with: (NeoJSONWriter toString: payload)
                type: ZnMimeType applicationJson
        ).

        response := client execute.
        json := NeoJSONReader fromString: response.

        (json isDictionary and: [ json includesKey: 'ranked_candidates' ])
            ifFalse: [ ^ anOrderedCollection ].

        rankedNames := json at: 'ranked_candidates'.

        (rankedNames isCollection and: [ rankedNames notEmpty ])
            ifFalse: [ ^ anOrderedCollection ].
    ]
        on: Error
        do: [ ^ anOrderedCollection ].

    "Map name -> queue of entries (duplicate-safe)"
    indexByName := Dictionary new.
    anOrderedCollection do: [ :entry |
        | name bucket |
        name := entry contents.
        bucket := indexByName
            at: name
            ifAbsentPut: [ OrderedCollection new ].
        bucket add: entry
    ].

    "Rebuild ranked entries"
    rankedEntries := OrderedCollection new: anOrderedCollection size.
    rankedNames do: [ :name |
        | bucket |
        bucket := indexByName at: name ifAbsent: [ nil ].
        (bucket notNil and: [ bucket notEmpty ])
            ifTrue: [ rankedEntries add: bucket removeFirst ]
    ].

    "Append leftovers"
    rankedEntries size < anOrderedCollection size ifTrue: [
        indexByName valuesDo: [ :bucket |
            rankedEntries addAll: bucket
        ]
    ].

    ^ rankedEntries

]
