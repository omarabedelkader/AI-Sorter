Class {
	#name : 'OMergedModel',
	#superclass : 'OModel',
	#category : 'AI-Sorter',
	#package : 'AI-Sorter'
}

{ #category : 'as yet unclassified' }
OMergedModel class >> latest [
        <ollamaInit: 'merged-model:latest'>
        ^ self new
                  tag: 'latest';
                  yourself
]

{ #category : 'accessing' }
OMergedModel >> name [

        ^ 'merged-model'
]
