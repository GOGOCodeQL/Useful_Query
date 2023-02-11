import go

newtype TIndex = 
    VariableIndex(DataFlow::SsaNode ssa) {
        exists(DataFlow::ElementReadNode ea | ea.getIndex() = ssa.getAUse())
    } or
    ConstantIndex(int v) {
        exists(DataFlow::ElementReadNode ea | ea.getIndex().getIntValue() = v)
    }

class Index extends TIndex {
    string toString() {
        exists(DataFlow::SsaNode ssa | 
            this = VariableIndex(ssa) and result = ssa.getSourceVariable().getName() + "<- hello!"
        ) or
        exists(int v |
            this = ConstantIndex(v) and result = v + "<<<-- Bye!")
    }
    DataFlow::Node getAUse() {
        exists(DataFlow::SsaNode ssa | 
            this = VariableIndex(ssa) and result = ssa.getAUse()
        ) or
        exists(int v |
            this = ConstantIndex(v) and result.getIntValue() = v
        )
    }
}

DataFlow::Node lengthCall_(DataFlow::SsaNode array) {
    result = Builtin::len().getACall() and
    result.(DataFlow::CallNode).getArgument(0) = array.getAUse()
}

DataFlow::Node lengthCall(DataFlow::SsaNode array) {
    (
        result.(DataFlow::BinaryOperationNode).getOperator() = "+" and
        (result.(DataFlow::BinaryOperationNode).getLeftOperand() = lengthCall(array) or
        result.(DataFlow::BinaryOperationNode).getRightOperand() = lengthCall(array))
    )
    or result = lengthCall_(array)
}


string x(DataFlow::RelationalComparisonNode z){
    result = z.getOperator()
}

ControlFlow::ConditionGuardNode existLEguard(DataFlow::SsaNode array,
     Index idx, DataFlow::ElementReadNode ea, int k) {
    result.ensuresLeq(idx.getAUse(), lengthCall(array), k)
    and ea.reads(array.getAUse(), idx.getAUse())
    and result.dominates(ea.getBasicBlock())
}

ControlFlow::ConditionGuardNode existLtguard(DataFlow::SsaNode array,
     Index idx, DataFlow::ElementReadNode ea, int k) {
    result.ensuresLeq(lengthCall(array),idx.getAUse(),0)
    and ea.reads(array.getAUse(), idx.getAUse())
    and existLEguard(array, idx, ea,k).dominates(ea.getBasicBlock())
    and k < 0
}

from DataFlow::SsaNode array, Index idx, DataFlow::ElementReadNode ea, ControlFlow::ConditionGuardNode res, int k
where res = existLEguard(array, idx, ea, k) and k >= 0
 or res = existLtguard(array, idx, ea, k)
select res, ea, array, idx
