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
			spec package: 'AI-Sorter' ]
]

{ #category : 'baselines' }
BaselineOfAISorter >> postLoad [

	CompletionContext sorterClass: NoSorter
]
