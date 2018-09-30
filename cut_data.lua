require "nn"

imgdir="data/img"
cutimgdir="data/img_cut"
lbldir="data/lbl"
cutlbldir="data/lbl_cut"
miplbldir="data/lbl_MIP"
cutmiplbldir="data/lbl_MIP_cut"

os.execute("mkdir "..cutimgdir)
os.execute("mkdir "..cutlbldir)
os.execute("mkdir "..cutmiplbldir)

function addMargin2D(lbl)
  local dilate=nn.SpatialMaxPooling( 5,5, 1,1, 2,2)
  local dili=dilate:forward(
    lbl:reshape(1,lbl:size(1),lbl:size(2)):double())
  dili:apply(function (x) if x>0 then return 1 else return 0 end end )
  lbl:mul(2):add(1)
  lbl:add(-1,dili:byte())
  return lbl
end

function project3DLbl(lbl)
  local l1=lbl:eq(2):max(1):squeeze()
  local l2=lbl:eq(2):max(2):squeeze()
  local l3=lbl:eq(2):max(3):squeeze()
  return {addMargin2D(l1), addMargin2D(l2), addMargin2D(l3)}
end

for f in paths.iterfiles(imgdir) do
  fn=paths.concat(imgdir,f)
  img=torch.load(fn)
  ln=paths.concat(lbldir,f)
  lbl=torch.load(ln)

  sz1=math.ceil(lbl:size(2)/2)
  sz2=math.ceil(lbl:size(3)/2)

  i1=img:narrow(3,1,sz1)
  i2=img:narrow(3,sz1+1,lbl:size(2)-sz1)

  i11=i1:narrow(4,1,sz2)
  i12=i1:narrow(4,sz2+1,lbl:size(3)-sz2)
  i21=i2:narrow(4,1,sz2)
  i22=i2:narrow(4,sz2+1,lbl:size(3)-sz2)
  torch.save(paths.concat(cutimgdir,f.."_11"),i11)
  torch.save(paths.concat(cutimgdir,f.."_12"),i12)
  torch.save(paths.concat(cutimgdir,f.."_21"),i21)
  torch.save(paths.concat(cutimgdir,f.."_22"),i22)

  l1=lbl:narrow(2,1,sz1)
  l2=lbl:narrow(2,sz1+1,lbl:size(2)-sz1)

  l11=l1:narrow(3,1,sz2)
  l12=l1:narrow(3,sz2+1,lbl:size(3)-sz2)
  l21=l2:narrow(3,1,sz2)
  l22=l2:narrow(3,sz2+1,lbl:size(3)-sz2)
  torch.save(paths.concat(cutlbldir,f.."_11"),l11)
  torch.save(paths.concat(cutlbldir,f.."_12"),l12)
  torch.save(paths.concat(cutlbldir,f.."_21"),l21)
  torch.save(paths.concat(cutlbldir,f.."_22"),l22)
  
  torch.save(paths.concat(cutmiplbldir,f.."_11"),project3DLbl(l11))
  torch.save(paths.concat(cutmiplbldir,f.."_12"),project3DLbl(l12))
  torch.save(paths.concat(cutmiplbldir,f.."_21"),project3DLbl(l21))
  torch.save(paths.concat(cutmiplbldir,f.."_22"),project3DLbl(l22))
end
