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

			spec
				baseline: 'ExtendedHeuristicCompletionBenchmarks'
				with: [ spec repository: 'github://omarabedelkader/HeuristicCompletion-Benchmarks/repository' ].

			spec baseline: 'Spec2' with: [ spec repository: 'github://pharo-spec/Spec' ].

			spec baseline: 'LevenshteinSorter' with: [ spec repository: 'github://omarabedelkader/Levenshtein-Sorter:main/src' ].

			spec baseline: 'Roassal' with: [
					spec
						repository: 'github://pharo-graphics/Roassal:Pharo' , SystemVersion current major asString;
						loads: 'Full' ].

			spec package: 'AI-Sorter'.
			spec package: 'AI-Sorter-Benchmarks' with: [ spec requires: #( 'AI-Sorter' ) ].
			spec package: 'AI-Sorter-Tests' with: [ spec requires: #( 'AI-Sorter' ) ] ]
]

{ #category : 'baselines' }
BaselineOfAISorter >> postLoad [

	"CompletionContext sorterClass: NoSorter"
]
