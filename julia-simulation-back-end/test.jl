#测试组件是否可用
include("./head.jl")
include("./components.jl")
include("./simulation.jl")

paras = Dict("inputdata" => Dict("制冷循环参数" => Dict("压缩机出口压力(pa)" =>4000000,
                                                       "节气门出口压力(pa)"=> 600000)),
             "mode" => 3)               
println(paras["inputdata"])
println(paras["mode"])

#println(paras)
figure,table = simulate!(paras["inputdata"],Val(paras["mode"]))
#for i in 1:10
    # try
    #     #paras["inputdata"]["制冷循环参数"]["压缩机出口压力(pa)"] = 1000000*i
    #     # 尝试执行可能会引发异常的代码
    #     figure,table = simulate!(paras["inputdata"],Val(paras["mode"]))
    #     println("执行成功，结果为: $result")
    # catch e
    #     # 捕获异常并处理
    #     println("出现异常: $e")
    # end
#end
