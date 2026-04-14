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

    | payload candidates |
    payload := Dictionary new.

    candidates := OrderedCollection new.
    candidateEntries withIndexDo: [ :each :index |
        candidates add: (Dictionary new
            at: 'id' put: index;
            at: 'text' put: ((each respondsTo: #contents)
                ifTrue: [ each contents ]
                ifFalse: [ each asString ]);
            yourself) ].

    payload at: 'context' put: textSoFar.
    payload at: 'candidates' put: candidates asArray.
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

    | client body |
    client := ZnClient new.
    client
        timeout: 30;
        url: ('http://', self host, ':', self port asString, '/', self path);
        method: #POST;
        contents: (NeoJSONWriter toString: aDictionary);
        contentType: ZnMimeType applicationJson;
        accept: ZnMimeType applicationJson.

    [ body := client execute ]
        on: Error
        do: [ :ex |
            self error: 'Reranker HTTP request failed: ', ex messageText ].

    client isSuccess ifFalse: [
        self error: 'Reranker server returned HTTP ', client response statusLine asString
    ].

    ^ NeoJSONReader fromString: body
]

{ #category : 're-ranking' }
ExternalRerankerAPI >> reRankCandidates: candidateEntries withContext: textSoFar [

    | payload json rankedIds ordered byId |

    candidateEntries ifEmpty: [ ^ candidateEntries ].

    [
        payload := self buildPayloadFor: candidateEntries context: textSoFar.
        json := self postJson: payload.
        rankedIds := json at: 'ranked_candidate_ids' ifAbsent: [ #() ].
    ] on: Error do: [ :ex |
        Transcript show: 'Reranker failed: ', ex messageText; cr.
        ^ candidateEntries
    ].

    rankedIds ifEmpty: [ ^ candidateEntries ].

    byId := Dictionary new.
    candidateEntries withIndexDo: [ :entry :index |
        byId at: index put: entry ].

    ordered := OrderedCollection new.

    rankedIds do: [ :eachId |
        | found |
        found := byId at: eachId ifAbsent: [ nil ].
        found ifNotNil: [ ordered add: found ] ].

    candidateEntries do: [ :entry |
        (ordered includes: entry) ifFalse: [ ordered add: entry ] ].

    ^ ordered asArray
]
