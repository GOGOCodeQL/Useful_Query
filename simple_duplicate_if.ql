import go

// if-else 체인에서 중복되는 조건을 탐지하는 쿼리


//if-else 체인에서 N 번째 condition 문을 가져옴
Expr getIthCond(IfStmt IF, int N){
    N = 0 and result = IF.getCond()
    or
    result = getIthCond(IF.getElse(), N - 1)
}

GVN getGVN(IfStmt IF, int idx, Expr exp){
    exp = getIthCond(IF, idx) and result = exp.getGlobalValueNumber()
}

from IfStmt X, int i, int j, Expr xx, Expr yy
where getGVN(X, i, xx) = getGVN(X, j, yy) and i < j
select yy, "is already checked by", xx, "!!!"
