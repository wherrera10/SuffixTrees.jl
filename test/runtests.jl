using SuffixTrees, Test

tests = [
    ("CAAAABAAAABD\$", "AAAAB"),
    ("GEEKSFORGEEKS\$", "GEEKS"),
    ("AAAAAAAAAA\$", "AAAAAAAAA"),
    ("ABCDEFG\$", ""),
    ("ABABABA\$", "ABABA"),
    ("ATCGATCGA\$", "ATCGA"),
    ("banana\$", "ana"),
    ("abcpqrabpqpq\$", "ab (or) pq"),
    ("pqrpqpqabab\$", "ab (or) pq"),
  	("CAAAABDAAAABD\$", "AAAABD"),
    ("CAAAABDAAAABD", "AAAABD"),
]
println("Longest Repeated Substring in:\n")
for (test, ans) in tests
    st = SuffixTree(test)
    @test getlongestrepeatedsubstring(st) == ans
end
