Class {
	#name : 'ExternalRerankerAPI',
	#superclass : 'Object',
	#instVars : [
		'host',
		'port',
		'path'
	],
	#category : 'AI-Sorter-new',
	#package : 'AI-Sorter',
	#tag : 'new'
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

{ #category : 'accessing' }
ExternalRerankerAPI >> host [

	^ host
]

{ #category : 'accessing' }
ExternalRerankerAPI >> host: anObject [

	host := anObject
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
        timeout: 30;
        url: ('http://', self host, ':', self port asString, '/', self path);
        method: #POST;
        contents: (NeoJSONWriter toString: aDictionary);
        contentType: ZnMimeType applicationJson;
        accept: ZnMimeType applicationJson.

    [ response := client execute ]
        on: Error
        do: [ :ex |
            self error: 'Reranker HTTP request failed: ', ex messageText ].

    response isSuccess ifFalse: [
        self error: 'Reranker server returned HTTP ', response statusLine asString
    ].

    ^ NeoJSONReader fromString: response contents
]

{ #category : 're-ranking' }
ExternalRerankerAPI >> reRankCandidates: candidateEntries withContext: textSoFar [ [

    | payload json rankedStrings ordered |
    candidateEntries ifEmpty: [ ^ candidateEntries ].

    [
        payload := self buildPayloadFor: candidateEntries context: textSoFar.
        json := self postJson: payload.
        rankedStrings := json at: 'ranked_candidates' ifAbsent: [ #() ].
    ] on: Error do: [ :ex |
        Transcript show: 'Reranker failed: ', ex messageText; cr.
        ^ candidateEntries
    ].

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

    candidateEntries do: [ :entry |
        (ordered includes: entry) ifFalse: [ ordered add: entry ] ].

    ^ ordered asArray
]
]
