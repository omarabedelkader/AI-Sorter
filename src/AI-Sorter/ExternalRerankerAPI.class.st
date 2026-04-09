Class {
	#name : 'ExternalRerankerAPI',
	#superclass : 'Object',
	#instVars : [
		'host',
		'port',
		'path'
	],
	#category : 'AI-Sorter-Archive',
	#package : 'AI-Sorter',
	#tag : 'Archive'
}

{ #category : 'private' }
ExternalRerankerAPI >> buildPayloadFor: candidateEntries context: textSoFar [

    | payload |
    payload := Dictionary new.
    payload at: 'context' put: textSoFar.
    payload at: 'candidates' put: (self candidateStringsFrom: candidateEntries).
    ^ payload
]

{ #category : 'private' }
ExternalRerankerAPI >> candidateStringsFrom: candidateEntries [ 

    ^ candidateEntries collect: [ :each |
        (each respondsTo: #contents)
            ifTrue: [ each contents ]
            ifFalse: [ each asString ] ]
]

{ #category : 'initialization' }
ExternalRerankerAPI >> initialize [ 

    super initialize.
    host := '127.0.0.1'.
    port := 8000.
    path := 'rerank'
]

{ #category : 'initialization' }
ExternalRerankerAPI >> path [

    ^ path
]

{ #category : 'initialization' }
ExternalRerankerAPI >> path: aString [

    path := aString
]

{ #category : 'initialization' }
ExternalRerankerAPI >> port [ 

    ^ port
]

{ #category : 'initialization' }
ExternalRerankerAPI >> port: anInteger [
    port := anInteger
]

{ #category : 'private' }
ExternalRerankerAPI >> postJson: aDictionary [

    | client response |
    client := ZnClient new.
    client
        url: ('http://', self host, ':', self port asString, '/', self path);
        method: #POST;
        entity: (
            ZnEntity
                with: (NeoJSONWriter toString: aDictionary)
                type: ZnMimeType applicationJson
        ).

    response := client execute.

    ^ NeoJSONReader fromString: response contents
]

{ #category : 're-ranking' }
ExternalRerankerAPI >> reRankCandidates: candidateEntries withContext: textSoFar [

    | payload json rankedStrings ordered |
    candidateEntries ifEmpty: [ ^ candidateEntries ].

    payload := self buildPayloadFor: candidateEntries context: textSoFar.
    json := self postJson: payload.

    rankedStrings := json at: 'ranked_candidates' ifAbsent: [ #() ].
    rankedStrings ifEmpty: [ ^ candidateEntries ].

    ordered := OrderedCollection new.

    rankedStrings do: [ :eachString |
        | found |
        found := candidateEntries
            detect: [ :entry |
                ((entry respondsTo: #contents)
                    ifTrue: [ entry contents ]
                    ifFalse: [ entry asString ]) = eachString ]
            ifNone: [ nil ].
        found ifNotNil: [ ordered add: found ] ].

    "Keep any missing originals at the end"
    candidateEntries do: [ :entry |
        (ordered includes: entry) ifFalse: [ ordered add: entry ] ].

    ^ ordered
]
