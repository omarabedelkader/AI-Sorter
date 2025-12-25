"
```st
| client payload response json scores ranked candidates |

candidates := #(
    'OrderedIdentityDictionaryTest'
    'OrderedDictionary'
    'OrderedCollection'
    'OrderedDictionaryTest'
).

client := ZnClient new
    url: 'http://127.0.0.1:8000/rank';
    method: #POST.

payload := Dictionary new
    at: 'context' put: 'Ordered';
    at: 'candidates' put: candidates;
    yourself.

client entity: (
    ZnEntity
        with: (NeoJSONWriter toString: payload)
        type: ZnMimeType applicationJson
).

""execute returns BODY (ByteString)""
response := client execute.

json := NeoJSONReader fromString: response.
scores := json at: 'scores'.

ranked := (candidates
    with: scores
    collect: [ :name :score | name -> score ])
    asSortedCollection: [ :a :b | a value > b value ].

ranked

```


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
	#name : 'CooStaticBenchmarksMessageSorter',
	#superclass : 'CooStaticBenchmarksMessage',
	#category : 'AI-Sorter-Benchmarks',
	#package : 'AI-Sorter-Benchmarks'
}

{ #category : 'accessing' }
CooStaticBenchmarksMessageSorter class >> nec [

	<script>
	^ self runAllSortersOnPackage: NECEntry package exportReportTo: 'nec-sorter-benchmarks.txt'
]
