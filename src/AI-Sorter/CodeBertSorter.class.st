Class {
	#name : 'CodeBertSorter',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter-Sorter',
	#package : 'AI-Sorter',
	#tag : 'Sorter'
}

{ #category : 'sorting' }
CodeBertSorter >> sortCompletionList: anOrderedCollection [
	| ctx candidates payload client response json rankedNames indexByName rankedEntries |

	anOrderedCollection size <= 1 ifTrue: [ ^ anOrderedCollection ].

	"Make context always JSON-safe and never nil"
	ctx := self context.
	(ctx isString) ifFalse: [ ctx := '' ].

	"Candidates we send to the server"
	candidates := anOrderedCollection collect: [ :each | each contents ].

	payload := Dictionary new
		at: 'context' put: ctx;
		at: 'candidates' put: candidates;
		yourself.

	[
		client := ZnClient new
			url: 'http://127.0.0.1:8000/rank';
			method: #POST.

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
		(rankedNames isCollection and: [ rankedNames size = candidates size ])
			ifFalse: [ ^ anOrderedCollection ].

	] on: Error do: [ ^ anOrderedCollection ].

	"Build mapping: name -> queue of entries (handles duplicates safely)"
	indexByName := Dictionary new.
	anOrderedCollection do: [ :entry |
		| name bucket |
		name := entry contents.
		bucket := indexByName at: name ifAbsentPut: [ OrderedCollection new ].
		bucket add: entry
	].

	"Rebuild ranked entries in server order"
	rankedEntries := OrderedCollection new: anOrderedCollection size.
	rankedNames do: [ :name |
		| bucket |
		bucket := indexByName at: name ifAbsent: [ nil ].
		(bucket isNil or: [ bucket isEmpty ])
			ifFalse: [ rankedEntries add: bucket removeFirst ].
	].

	"Fallback: if something went wrong (missing/extra), append leftovers"
	(rankedEntries size < anOrderedCollection size) ifTrue: [
		indexByName valuesDo: [ :bucket | rankedEntries addAll: bucket ].
	].

	^ rankedEntries

]
