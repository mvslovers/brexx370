/*1
"ability"            "learning"          "grouping"
"basal"              "evaluative"        "modification"
"behavioral"         "objective"         "accountability"
"child-centered"     "congnitive"        "process"
"differentiated"     "enrichment"        "core curriculum"
"discovery"          "scheduling"        "algorithm"
"flexible"           "humanistic"        "performance"
"heterogeneous"      "integrated"        "reinforcement"
"homogeneous"        "non-graded"        "open classroom"
"manipulative"       "training"          "resource"
"modular"            "vertical"age       "structure"
"tavistock"          "monivational"      "facility"
"individualized"     "creative"          "enviroment"
*/
/*2
"integrated"           "management"           "options"
"total"                "organizational"       "flexibility"
"systematized"         "monitored"            "capability"
"parallel"             "reciprocal"           "mobility"
"functional"           "digital"              "programming"
"responsive"           "logistical"           "concept"
"optional"             "transitional"         "time-phase"
"synchronized"         "incremental"          "projection"
"compatible"           "third-generation"     "hardware"
"balanced"             "policy"               "contingency"
*/

/*
The procedure is simple.  Think of any three-digit number, then select
the corresponding buzzword from each column.  For instance, number 257 produces
"systematized logistical projection," a phrase that can be dropped into
virtually any report with that ring of decisive, knowledgeable authority.  "No
one will have the remotest idea of what you're talking about," says Broughton,
"but the important thing is that they're not about to admit it."
                -- Philip Broughton, "How to Win at Wordsmanship"
*/
Arg set
If set="" Then set = Random(1,2)
If datatype(set)^="NUM" Then set=1

/* find set */
A.0 = 0
Do Line = 1
    L = Sourceline(Line)
    If L="/*"set Then Do
        Do i=1
            Line = Line + 1
            L = Sourceline(Line)
            If L="*/" Then Leave
            Parse Var L '"' A.i '"' . '"' B.i '"' . '"' C.i '"'
        End
        A.0 = i-1
        Leave
    End
End
If A.0 = 0 Then Do
    Say "Set" set "not found"
    Exit
End

A = Random(,,Time('s'))

Do 10
   A = Random(1,A.0) ; B = Random(1,A.0) ; C = Random(1,A.0)
   Say A.A  B.B   C.C
End
