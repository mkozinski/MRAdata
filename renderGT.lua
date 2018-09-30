require "nn"
dofile "renderTRE2volume.lua"

function addMargin3D(lbl)
  local dilate=nn.VolumetricMaxPooling( 5,5,5, 1,1,1, 2,2,2)
  local dili=dilate:forward(
    lbl:reshape(1,lbl:size(1),lbl:size(2),lbl:size(3)))
  dili:apply(function (x) if x>0 then return 1 else return 0 end end )
  lbl:mul(2):add(1)
  lbl:add(-1,dili)
  return lbl
end

function addMargin2D(lbl)
  local dilate=nn.SpatialMaxPooling( 5,5, 1,1, 2,2)
  local dili=dilate:forward(
    lbl:reshape(1,lbl:size(1),lbl:size(2)))
  dili:apply(function (x) if x>0 then return 1 else return 0 end end )
  lbl:mul(2):add(1)
  lbl:add(-1,dili)
  return lbl
end

function addMargin2DMIP(mipLbl)
  return {addMargin2D(mipLbl[1]), addMargin2D(mipLbl[2]), addMargin2D(mipLbl[3])}
end

function project3DLbl(lbl)
  return {lbl:max(1):squeeze(), lbl:max(2):squeeze(), lbl:max(3):squeeze()}
end

local indir="orig_data/lbl"
local odir="lbl"
local odirMIP="lbl_MIP"

os.execute("mkdir "..odir)
os.execute("mkdir "..odirMIP)

local gt=torch.Tensor(128,448,448)
for f in paths.iterfiles(indir) do
  local fn=paths.concat(indir,f)
  gt:zero()
  renderTrace2Volume(fn,torch.Tensor{3,2,1},torch.Tensor{1,1,1},gt)
  local gtMip=project3DLbl(gt)
  local gtMargin=addMargin3D(gt)
  local gtMipMargin=addMargin2DMIP(gtMip)
  torch.save(paths.concat(odir,f:sub(1,-5)),gtMargin)
  torch.save(paths.concat(odirMIP,f:sub(1,-5)),gtMipMargin)
end
