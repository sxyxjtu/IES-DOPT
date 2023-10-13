using Plots   
include("function.jl")     
#朗肯循环
simulate!(paras,::Val{1}) = rankine(paras["朗肯循环参数"]["冷凝器冷却压力(pa)"], 
                              paras["朗肯循环参数"]["水泵供给压力(pa)"], 
                              paras["朗肯循环参数"]["锅炉出口温度(k)"])

#有再热的朗肯循环
simulate!(paras,::Val{2}) = reheat_rankine(paras["再热循环参数"]["冷凝器冷却压力(pa)"],
                                           paras["再热循环参数"]["水泵供给压力(pa)"],
                                           paras["再热循环参数"]["锅炉出口温度(k)"],
                                           paras["再热循环参数"]["再热器出口温度(k)"],
                                           paras["再热循环参数"][ "汽轮机一级出口压力(pa)"])
    
                                       

function reheat_rankine(冷凝器冷却压力,
                        水泵供给压力,
                        锅炉出口温度,
                        再热器出口温度,
                        汽轮机一级出口压力)
    #创建组件...
    @named pump = Pump(P = 水泵供给压力)
    @named boiler = Boiler(T = 锅炉出口温度)
    @named turbine = Turbine(P = 汽轮机一级出口压力)
    @named reboiler = Boiler(T = 再热器出口温度)
    @named returbine = Turbine(P = 冷凝器冷却压力)
    @named condenser = Condenser()
    
    #构建连接关系
    rc_eqs = [
      connect(pump.out, boiler.in)
      connect(boiler.out, turbine.in)
      connect(turbine.out, reboiler.in)
      connect(reboiler.out, returbine.in)
      connect(returbine.out, condenser.in)
      connect(condenser.out, pump.in)
      D(x) ~ 0
    ]
    @named _rc_model = ODESystem(rc_eqs, t0) #连接关系也需要放到ODESystem中
  
    # 组件与组件连接关系一起构建系统
    @named rc_model = compose(_rc_model,[turbine, condenser , pump, boiler,reboiler,returbine ])
  
    # 系统化简
    sys = structural_simplify(rc_model)
    equations(sys) # 查看方程
    # 求解
    prob = ODAEProblem(sys, [0], (0, 0.0))
    sol = solve(prob)
    
    #println(sol)
    table = OrderedDict("汽轮机一级入口压力(pa)" => sol[turbine.in.p][1],
    "汽轮机一级入口温度(k)" => sol[turbine.in.t][1],
    "汽轮机一级出口温度(k)" => sol[turbine.out.t][1],
    "汽轮机一级出口熵(J/(mol*k))" => sol[turbine.out.s][1],
    "锅炉入口温度(k)"=> sol[boiler.in.t][1],
    "锅炉出口压力(pa)"=> sol[boiler.out.p][1],
    "锅炉入口压力(pa)"=> sol[boiler.in.p][1])

    plot_sys = [pump, boiler, turbine, reboiler, returbine, condenser];
    propx = :s
    propy = :t
    
    ss = [sol[getproperty(i.out, propx)][1] for i in plot_sys]
    tt = [sol[getproperty(i.out, propy)][1] for i in plot_sys]

    xAxis = collect(range(ss[1], ss[2], 15))
    yAxis = CoolProp.PropsSI.("T", "P", sol[pump.out.p], "S", collect(range(ss[1], ss[2], 15)), "Water")
    
    append!(xAxis, collect(range(ss[2], ss[3], 15)))
    append!(yAxis,collect(range(tt[2], tt[3], 15)))
    
    append!(xAxis,collect(range(ss[3], ss[4], 15)))
    append!(yAxis,CoolProp.PropsSI.("T", "P", sol[reboiler.out.p], "S", collect(range(ss[3], ss[4], 15)), "Water"))
    
    append!(xAxis,collect(range(ss[4], ss[5], 15)))
    append!(yAxis,collect(range(tt[4], tt[5], 15)))

    append!(xAxis,collect(range(ss[5], ss[6], 15)))
    append!(yAxis,collect(range(tt[5], tt[6], 15)))
    
    append!(xAxis,collect(range(ss[6], ss[1], 15)))
    append!(yAxis,collect(range(tt[6], tt[1], 15)))
    # println(xAxis)
    # println(yAxis)
    figure = transposeMatrix(xAxis, yAxis)
    #在本地绘图
    plot_local(figure)
    return figure,table
end

@info "开始建模..."
function rankine(汽轮机出口压力 = 150000 ,
  水泵出口压力 = 700000,
  锅炉出口温度 = 700)
    @info "创建组件..."
      @named turbine = Turbine(P = 汽轮机出口压力)
      @named condenser = Condenser()
      @named pump = Pump(P = 水泵出口压力)
      @named boiler = Boiler(T = 锅炉出口温度)
  
    @info "创建系统..."
  # 构建连接关系
  rc_eqs = [
      connect(turbine.out, condenser.in)
      connect(condenser.out,pump.in)
      connect(pump.out,boiler.in)
      connect(boiler.out,turbine.in)
      D(x) ~ 0
  ]
  @named _rc_model = ODESystem(rc_eqs, t0) #连接关系也需要放到ODESystem中
  
  # 组件与组件连接关系一起构建系统
  @named rc_model = compose(_rc_model,[turbine, condenser , pump, boiler ])
  
  # 系统化简
  @info "系统化简..."
  sys = structural_simplify(rc_model)
  #equations(sys) # 查看方程
  
  # 求解
  @info "创建仿真..."
  prob = ODAEProblem(sys, [0], (0, 0.0))
  
  @info "仿真计算..."
  sol = solve(prob)
  
  @info "系统评价..."
  table = OrderedDict("汽轮机入口压力(pa)" => sol[turbine.in.p][1],
  "汽轮机入口温度(k)" => sol[turbine.in.t][1],
  "汽轮机出口温度(k)" => sol[turbine.out.t][1],
  "锅炉入口温度(k)"=> sol[boiler.in.t][1],
  "锅炉出口压力(pa)"=> sol[boiler.out.p][1],
  "锅炉入口压力(pa)"=> sol[boiler.in.p][1])
  
  plot_sys = [pump, boiler, turbine, condenser];
  propx = :s
  propy = :t
  
  ss = [sol[getproperty(i.out, propx)][1] for i in plot_sys]
  tt = [sol[getproperty(i.out, propy)][1] for i in plot_sys]

  xAxis = collect(range(ss[1], ss[2], 15))
  yAxis = CoolProp.PropsSI.("T", "P", sol[pump.out.p], "S", collect(range(ss[1], ss[2], 15)), "Water")
  
  append!(xAxis,collect(range(ss[2], ss[3], 15)))
  append!(yAxis,collect(range(tt[2], tt[3], 15)))
  
  append!(xAxis,collect(range(ss[3], ss[4], 15)))
  append!(yAxis,CoolProp.PropsSI.("T", "P", sol[turbine.out.p], "S", collect(range(ss[3], ss[4], 15)), "Water"))
  
  append!(xAxis,collect(range(ss[4], ss[1], 15)))
  append!(yAxis,collect(range(tt[4], tt[1], 15)))
  
  figure = transposeMatrix(xAxis, yAxis)
  #在本地绘图
  plot_local(figure)
  
  return figure,table
end




