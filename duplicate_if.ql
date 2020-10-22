import go
//예시 쿼리 따라구현

Expr getNthCondition(IfStmt IF, int N){
    result = IF.getCond() and N = 0
    or
    result = getNthCondition(IF.getElse(), N - 1)   //else 에서 N-1 번쨰 조건을 가져옴
    and
    exists(IfStmt elseif | elseif = IF.getElse() and    //else 에 init 조건이 없는 경우에 한하여
        not exists(elseif.getInit())
    )
}

GVN getGVN(IfStmt IF, int i, Expr ex){
    ex = getNthCondition(IF, i) and result = ex.getGlobalValueNumber()
}

from IfStmt IF, int i, int j, Expr e1, Expr e2
where getGVN(IF, i, e1) = getGVN(IF, j, e2) and i < j
select e2, "is deadcode", e1
