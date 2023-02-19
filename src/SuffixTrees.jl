module SuffixTrees

export Node, SuffixTree, dotraversal, getlongestrepeatedsubstring

const oo = typemax(Int)

"""
    mutable struct Node

        The suffix-tree's node.
Note that these are referenced not by pointer but by an index into an array of nodes.
"""
mutable struct Node
    children::Dict{Char,Int}
    start::Int
    ending::Int
    suffixlink::Int
    suffixindex::Int
    Node(strt = 0, endng = oo) = new(Dict{Char,Int}(), strt, endng, 0, -1)
end


""" Ukkonen Suffix-Tree """
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

""" 
    edgelength(st, n::Node)

length of edge of a node (the portion of the sequence it covers)
"""
edgelength(st, n::Node) = min(n.ending, st.position + 1) - n.start

""" 
    newnode(st, start, ending)

make a node for the tree
"""
function newnode(st, start, ending)
    st.currentnode += 1
    st.nodes[st.currentnode] = Node(start, ending)
    return st.currentnode
end

""" 
    SuffixTree(str::String, addterminator = true, terminatorchar = Char(65129))

Constructor for Ukkonen Suffix-Tree. First argument can be a char vector.
If addterminator is true (default), add a terminator if the last char is not unique.
"""
function SuffixTree(str::String, addterminator = true, terminatorchar = Char(65129))
    if addterminator && str[end] in str[begin:end-1] # terminator not unique
        while terminatorchar in str
            terminatorchar = Char(Int(terminatorchar) + 1)
        end
        str *= terminatorchar
    end
    nodes = [Node() for _ = 1:length(str)*2]
    st = SuffixTree(nodes, collect(str), 1, 0, 0, 0, 0, 1, 1, 1)
    st.root = newnode(st, 0, 0)
    st.activenode = st.root
    for i in eachindex(st.text)
        extendsuffixtree(st, i)
    end
    setsuffixindexbyDFS(st, st.nodes[st.root], 0)
    return st
end
SuffixTree(chars::Vector, addterm = true) = SuffixTree(String(chars), addterm)


"""
    addsuffixlink(st, nodenum::Int)

Add a link to the suffix-tree
"""
function addsuffixlink(st, nodenum::Int)
    if st.needsuffixlink > 0
        st.nodes[st.needsuffixlink].suffixlink = nodenum
    end
    st.needsuffixlink = nodenum
end

"""
    activeedge(st)

Get the active edge of the tree construction
"""
activeedge(st) = st.text[st.activeedge]

""" 
    walkdown!(st, currnode::Int)

Walk down the tree to its active length
"""
function walkdown!(st, currnode::Int)
    len = edgelength(st, st.nodes[currnode])
    st.activelength < len && return false
    st.activeedge += len
    st.activelength -= len
    st.activenode = currnode
    return true
end

"""
   extendsuffixtree(st, pos)

Extend tree construction by a character at position pos
"""
function extendsuffixtree(st, pos)
    st.position = pos
    st.needsuffixlink = 0
    st.remainder += 1
    while st.remainder > 0
        st.activelength == 0 && (st.activeedge = st.position)
        if !haskey(st.nodes[st.activenode].children, activeedge(st))
            nodenum = newnode(st, st.position, oo)
            st.nodes[st.activenode].children[activeedge(st)] = nodenum
            addsuffixlink(st, st.activenode)
        else
            next = st.nodes[st.activenode].children[activeedge(st)]
            walkdown!(st, next) && continue
            if st.text[st.nodes[next].start+st.activelength] == st.text[pos]
                addsuffixlink(st, st.activenode)
                st.activelength += 1
                break
            end
            splt = newnode(st, st.nodes[next].start, st.nodes[next].start + st.activelength)
            st.nodes[st.activenode].children[activeedge(st)] = splt
            nodenum = newnode(st, st.position, oo)
            st.nodes[splt].children[st.text[pos]] = nodenum
            st.nodes[next].start += st.activelength
            st.nodes[splt].children[st.text[st.nodes[next].start]] = next
            addsuffixlink(st, splt)
        end
        st.remainder -= 1
        if st.activenode == st.root && st.activelength > 0
            st.activelength -= 1
            st.activeedge = st.position - st.remainder + 1
        elseif st.activenode != st.root
            st.activenode = st.nodes[st.activenode].suffixlink
        end
    end
end

""" 
    setsuffixindexbyDFS(st, node, labelheight, verbose=false)

Set the index of the leaves of the tree within the sequence
"""
function setsuffixindexbyDFS(st, node, labelheight, verbose = false)
    verbose &&
        node.start > 0 &&
        print(st.text[node.start:min(node.ending, length(st.text))])
    isleaf = true
    for child in map(v -> st.nodes[v], values(node.children))
        verbose && isleaf && node.start > 0 && println(" [", node.suffixindex, "]")
        isleaf = false
        setsuffixindexbyDFS(st, child, labelheight + edgelength(st, child))
    end
    if isleaf
        idx = length(st.text) - labelheight
        node.suffixindex = idx
        verbose && println(" [$idx]")
    end
end

""" 
    dotraversal(st)

Traverse the suffix tree st.
"""
function dotraversal(st)
    maxheight, substringstartindices = 0, [0]
    function traversal(node::Node, labelheight)
        if node.suffixindex == -1
            for child in map(v -> st.nodes[v], values(node.children))
                traversal(child, labelheight + edgelength(st, child))
            end
        elseif maxheight < labelheight - edgelength(st, node)
            maxheight = labelheight - edgelength(st, node)
            substringstartindices = [node.suffixindex + 1]
        elseif maxheight == labelheight - edgelength(st, node)
            push!(substringstartindices, node.suffixindex + 1)
        end
    end
    traversal(st.nodes[st.root], 0)
    return maxheight, substringstartindices
end

"""
    getlongestrepeatedsubstring(st::SuffixTree, label="", printresult=true)

Find the longest repeated suffix of the tree. Defaults to printing results.
"""
function getlongestrepeatedsubstring(st::SuffixTree, label = "", printresult = true)
    len, starts = dotraversal(st)
    substring =
        len == 0 ? "" : join(unique(map(x -> String(st.text[x:x+len-1]), starts)), " (or) ")
    if printresult
        print("  ", label == "" ? String(st.text) : label, ": ")
        println(len == 0 ? "No repeated substring." : substring)
    end
    return substring
end

end # module
