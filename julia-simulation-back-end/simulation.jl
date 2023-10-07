
           
simulate!(paras) = simulation(paras["汽轮机出口压力"], 
                              paras["水泵出口压力"], 
                              paras["锅炉出口温度"])



@info "开始建模..."
function simulation(汽轮机出口压力 = 100000 ,
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
  Data = OrderedDict("汽轮机入口压力" => sol[turbine.in.p][1],
  "汽轮机入口温度" => sol[turbine.in.t][1],
  "汽轮机出口温度" => sol[turbine.out.t][1],
  "锅炉入口温度"=> sol[boiler.in.t][1],
  "锅炉出口压力"=> sol[boiler.out.p][1],
  "锅炉入口压力"=> sol[boiler.in.p][1])
  
  #df = DataFrame(; items=collect(keys(dict_res)), value=collect(values(dict_res)))
  return Data
end

# getTableData(table) = [Dict("items" => k, "value" => round(v, digits=2)) for (k, v) in table]


