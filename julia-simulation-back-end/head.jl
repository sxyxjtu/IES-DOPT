
@info "加载包(head)..."
  using ModelingToolkit
  using DifferentialEquations
  using CoolProp
  using OrderedCollections
#import CoolProp.PropsSI
  PropsSI(out::AbstractString, name1::AbstractString, value1::Real, name2::AbstractString, value2::Real, fluid::AbstractString) = CoolProp.PropsSI(out, name1, value1, name2, value2, fluid)
  @register_symbolic PropsSI(out::AbstractString, name1::AbstractString, value1::Real, name2::AbstractString, value2::Real, fluid::AbstractString)

@info "定义工质..."
# fluid = "Water"

# 定义独立时间变量
@info "定义变量..."
@variables t0
@variables x(t0)

D = Differential(t0)

