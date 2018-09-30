function traceLine(lbl,endPoints)
  local d=endPoints[2]-endPoints[1]
  local s=endPoints[1]
  local _,mi=torch.max(torch.abs(d),1)
  local mi=mi[1]
  local coef=d/d[mi]
  for t=0,d[mi],d[mi]/math.abs(d[mi]) do
    local pos=torch.add(s,torch.mul(coef,t):add(-0.5):ceil())
    lbl[pos:totable()]=1
  end
  return lbl
end
