dofile "traceLine.lua"

function volInds(swcCoords,dr,vd)
  local sc=swcCoords:cdiv(dr)
  local volCoords=torch.Tensor(3):zero()
  volCoords[vd[1]]=math.floor(sc[1]+0.5)
  volCoords[vd[2]]=math.floor(sc[2]+0.5)
  volCoords[vd[3]]=math.floor(sc[3]+0.5)
  return volCoords+1
end

function renderTrace2Volume(tracefname, volumeDims, dimRes, volCL)
--[[
  tracefname 	name of the trace file
  volumeDims	three-dimensional tensor;
		volumeDims[1] is index of volCL dimension corresponding to X
		volumeDims[2] is index of volCL dimension corresp to Y
		volumeDims[3] is index of volCL dimension corresp to Z
		X,Y,Z are as interpreted in the CWS format
  dimsRes	three-dimensional tensor; 
		dimsRes[1] is the spatial resolution of the volume in X dim
		dimsRes[2] is the spatial resolution of the volume in Y dim
		dimsRes[3] is the spatial resolution of the volume in Z dim
		note these are X,Y,Z of the trace file, not dim 1,2,3 of volCL
  volCL		tensor into which we will render ground truth centerlines
--]]

  local nodes
  local parts={}
  local lastletters=true -- last read line contained letters (2-state autom)
  -- read parts of the trace
  for l in io.lines(tracefname) do
    if l:match("^%s*%a+") then --new line
      lastletters=true 
    else --continue old line
      local a,b,c,d=l:match("%s*([0-9%-%.eE]+)%s*([0-9%-%.eE]+)%s*([0-9%-%.eE]+)%s*([0-9%-%.eE]+)")
      local node={}
      if lastletters then -- inserting new line
        nodes={}
        table.insert(parts,nodes)
        lastletters=false
      end
      node.x=tonumber(a)
      node.y=tonumber(b)
      node.z=tonumber(c)
      node.radius=tonumber(d)
      table.insert(nodes,node)
    end
  end
  -- render parts of the trace
  for kk,vv in pairs(parts) do
    nodes=vv
    local prev
    prev=nil
    -- render linear sections between the nodes of individual parts of the trace
    for k,v in pairs(nodes) do
      if prev then
        inds=volInds(torch.Tensor{v.x,v.y,v.z},dimRes,volumeDims)
        indsp=volInds(torch.Tensor{prev.x,prev.y,prev.z},dimRes,volumeDims)
        if not torch.all(indsp:eq(inds)) then
          traceLine(volCL,torch.cat({indsp:reshape(1,3),inds:reshape(1,3)},1))
        end
      end
      prev=v
    end
  end
end

