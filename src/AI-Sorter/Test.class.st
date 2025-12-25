Class {
	#name : 'Test',
	#superclass : 'CompletionSorter',
	#category : 'AI-Sorter-Sorter',
	#package : 'AI-Sorter',
	#tag : 'Sorter'
}

{ #category : 'sorting' }
Test >> levenshtein: s with: t [
    | m n d cost |
    m := s size.
    n := t size.
    m = 0 ifTrue: [ ^ n ].
    n = 0 ifTrue: [ ^ m ].
    
    d := Array new: (m + 1) * (n + 1).
    
    0 to: m do: [ :i | d at: i * (n + 1) + 1 put: i ].
    0 to: n do: [ :j | d at: j + 1 put: j ].
    
    1 to: m do: [ :i |
        1 to: n do: [ :j |
            cost := (s at: i) = (t at: j) ifTrue: [ 0 ] ifFalse: [ 1 ].
            d at: i * (n + 1) + j + 1 put: (
                (((d at: (i - 1) * (n + 1) + j + 1) + 1) min:
                 ((d at: i * (n + 1) + j) + 1)) min:
                 ((d at: (i - 1) * (n + 1) + j) + cost)
            )
        ]
    ].
    
    ^ d at: m * (n + 1) + n + 1
]

{ #category : 'sorting' }
Test >> sortCompletionList: anOrderedCollection [
    ^ anOrderedCollection sort: [ :a :b | 
        | aString bString avgDistA avgDistB |
        aString := a contents asString.
        bString := b contents asString.
        
        avgDistA := (anOrderedCollection collect: [ :entry | 
            self levenshtein: aString with: entry contents asString
        ]) average.
        
        avgDistB := (anOrderedCollection collect: [ :entry |
            self levenshtein: bString with: entry contents asString  
        ]) average.
        
        avgDistA <= avgDistB
    ]

]
