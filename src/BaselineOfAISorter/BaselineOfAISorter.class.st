Class {
	#name : 'BaselineOfAISorter',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfAISorter',
	#package : 'BaselineOfAISorter'
}

{ #category : 'baselines' }
BaselineOfAISorter >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec postLoadDoIt: #postLoad.
			spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].

			spec package: 'AI-Sorter'.
			spec package: 'AI-Sorter-Exporter' with: [ spec requires: #( 'AI-Sorter' ) ].
			spec package: 'AI-Sorter-Benchmarks' with: [ spec requires: #( 'AI-Sorter' ) ].
			spec package: 'AI-Sorter-Tests' with: [ spec requires: #( 'AI-Sorter' ) ] ]
]

{ #category : 'baselines' }
BaselineOfAISorter >> postLoad [

	CompletionContext sorterClass: NoSorter
]
