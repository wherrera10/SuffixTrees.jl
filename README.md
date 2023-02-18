# SuffixTrees.jl

Julia implementation of the Ukkonen suffix tree algorithm

<img src="https://github.com/wherrera10/SuffixTrees.jl/blob/master/docs/src/stree.png">

## Functions

	mutable struct Node
	    children::Dict{Char, Int}
	    start::Int
	    ending::Int
	    suffixlink::Int
	    suffixindex::Int
	end

The suffix-tree's node.
Note that these are referenced not by pointer but by an index into an array of nodes.
<br /><br />

   Node()
   Node(start, ending)
   
Node constructors
<br /><br />



	mutable struct SuffixTree
	    nodes::Vector{Node}
	    text::Vector{Char}
	    root::Int
	    position::Int
	    currentnode::Int
	    needsuffixlink::Int
	    remainder::Int
	    activenode::Int
	    activelength::Int
	    activeedge::Int
	end

The SuffixTree struct.
<br /><br />


    function SuffixTree(str::String)

SuffixTree constructor from string. Note that the string should have a terminator character at its end, ususally '$' or '#'.
<br /><br />


    edgelength(st, n::Node)
    
Return length of edge of a node (the portion of the sequence it covers) """
<br /><br />


    function newnode(st, start, ending)
  
Make a node for the tree
<br /><br />


    function addsuffixlink(st, nodenum::Int)
    
Add a link to tree
<br /><br />


    activeedge(st)
    
Return active edge of tree
<br /><br />


    function walkdown!(st, currnode::Int)

Walk down the tree to its active length
<br /><br />

    
    function extendsuffixtree(st, pos)

Extend tree at pos
<br /><br />


    function setsuffixindexbyDFS(st, node, labelheight, verbose=false)

Set the index of the leaves of the tree within the sequence
<br /><br />


    function dotraversal(st)

Traverse the suffix tree
<br /><br />


    function getlongestrepeatedsubstring(st::SuffixTree, label="", printresult=true)

Find the longest repeated suffix of the tree
<br /><br />

## Example
  
	using SuffixTrees
	
	examples = [
	    ("CAAAABAAAABD\$", "AAAAB"),
	    ("GEEKSFORGEEKS\$", "GEEKS"),
	    ("AAAAAAAAAA\$", "AAAAAAAAA"),
	    ("ABCDEFG\$", ""),
	    ("ABABABA\$", "ABABA"),
	    ("ATCGATCGA\$", "ATCGA"),
	    ("banana\$", "ana"),
	    ("abcpqrabpqpq\$", "ab (or) pq"),
	    ("pqrpqpqabab\$", "ab (or) pq"),
	]
	
	println("Test Longest Repeated Substring in:\n")
	for (ex, ans) in examples
	    st = SuffixTree(ex)
	    println("Check: ", getlongestrepeatedsubstring(st), " == $ans")
	end
	

