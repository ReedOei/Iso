module ISO-SYNTAX
    imports DOMAINS
    imports BUILTIN-ID-TOKENS

    syntax Name ::= "$x"
                  | #LowerId

    syntax Exp ::= Int | Name
                 | "Nats"
                 | "Ints"
                 | Exp "->" Exp
                 | Name "|-->" Exp
                 | "(" Exp ")" [bracket]
                 | "{" Exps "}"
                 | "Union" "(" Exps ")"
    syntax Exps ::= List{Exp,","}

    syntax Stmt ::= "Define" Name ":=" Exp "."
                  | "Compute" Exp "."

    syntax Prog ::= List{Stmt,""}
endmodule

module ISO
    imports DOMAINS
    imports ISO-SYNTAX

    syntax Val ::= member(Exp, Val)
                 | powerset(Val)
                 | union(Set)
                 | set(Exp)

    configuration
        <T>
            <k> $PGM:Prog </k>
            <defs> .Map </defs>
            <embeddings> Nats |-> SetItem(member($x |--> $x, set(Nats -> Ints))) </embeddings>
        </T>

    rule .Prog => .
    rule S:Stmt P:Prog => S ~> P

    rule <k> Define A := E . => . ... </k>
        <defs> ... .Map => A |-> member(E, resolveSet(E)) </defs>

    syntax Val ::= resolveSet(Exp) [function]

    rule resolveSet(I:Int) => set(Nats)
        requires I >=Int 0
    rule resolveSet(I:Int) => set(Ints)
        requires I <Int 0

    rule resolveSet({ Es }) => union(resolveSets(Es))

    syntax Exps ::= list2Exps(List) [function]
    rule list2Exps(.List) => .Exps
    rule list2Exps(ListItem(A) Rest) => A, list2Exps(Rest)

    syntax Set ::= resolveSets(Exps) [function]
    rule resolveSets(.Exps) => .Set
    rule resolveSets(E, Es) => SetItem(resolveSet(E)) |Set resolveSets(Es)
endmodule

