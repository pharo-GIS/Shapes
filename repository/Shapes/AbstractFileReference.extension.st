Extension { #name : #AbstractFileReference }

{ #category : #'*Shapes' }
AbstractFileReference >> withExtension: extString [
	" Answer the receiver replacing the extension with extString "
	
	^ self asPath withExtension: extString

]
