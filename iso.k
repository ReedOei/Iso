module ISO-SYNTAX
    imports DOMAINS-SYNTAX
    imports BUILTIN-ID-TOKENS

    syntax Name ::= "$x"
                  | #LowerId

    syntax Exp ::= Int | Name
                 | "Nats"
                 | "Ints"
                 | "Maps" "(" Exp "," Exp ")"
                 | "function" "(" Exp "," Exp "," Exp ")"
                 | Name "|-->" Exp
                 | "(" Exp ")" [bracket]
    syntax Exps ::= List{Exp,","}

    syntax Val ::= member(Exp, Val)
                 | set(Exp)

    syntax Stmt ::= "Define" Name ":=" Exp "."
                  | "Compute" Exp "."

    syntax Prog ::= List{Stmt,""}
endmodule

module ISO
    imports DOMAINS
    imports ISO-SYNTAX

    configuration
        <T>
            <k> $PGM:Prog </k>
            <defs> .Map </defs>
            <embeddings> Nats |-> SetItem(function(Nats, Ints, $x |--> $x)) </embeddings>
        </T>

    rule .Prog => .
    rule S:Stmt P:Prog => S ~> P

    rule <k> Define A := E . => . ... </k>
        <defs> ... .Map => A |-> resolveSets(E) </defs>

    syntax Val ::= resolveSets(Exp) [function]

    rule resolveSets(I:Int) => member(I, set(Nats))
        requires I >=Int 0
    rule resolveSets(I:Int) => member(I, set(Ints))
        requires I <Int 0
endmodule

