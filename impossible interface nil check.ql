/*
    인터페이스 타입의 변수 xx 에 Interface타입이 아니거나 nil literfal 이 아닌 값을 넣고,
    해당 변수 xx 를 nil 과 비교하는 경우 경고문을 띄우는 쿼리


    인터페이스 타입와 nil 을 비교하는 부분을 찾음 - 이를 N이라고 부르자
    if err != nil
    if err == nil

    특정 노드가 N까지 흘러들어갈 수 있는지 확인
    x := err
    if x != nil

    N까지 흘러갈 가능성이 있는 노드에 Interface, nil 이 아닌 타입이 들어가면?

    경고!!

    GOGO
*/
import go
predicate isEqualInterfaceWithNil(DataFlow::EqualityTestNode eq,DataFlow::Node n) {
    eq.getAnOperand() = n
    and n.getType().getUnderlyingType() instanceof InterfaceType
    and eq.getAnOperand().getType() instanceof NilLiteralType
}

predicate canFlowToInterfaceEqNil(DataFlow::Node n){
    isEqualInterfaceWithNil(_, n)

    /*
        This recursion finishes 
            when [isEqualInterfaceWithNil is true] or [n doesn't have a successor]
    */
    or canFlowToInterfaceEqNil(n.getASuccessor())
}

predicate nonInterfaceWrapper(DataFlow::Node n){
    canFlowToInterfaceEqNil(n)
    and (
            forex(DataFlow::Node pred | pred = n.getAPredecessor() |
                nonInterfaceWrapper(pred)
                or (
                    exists(Type t | 
                        t = pred.getType().getUnderlyingType()
                        and not t instanceof InterfaceType
                        and not t instanceof NilLiteralType
                    )
                )
            )    
    )
}


from DataFlow::Node n
where nonInterfaceWrapper(n)// and isEqualInterfaceWithNil(_, n)
select n
