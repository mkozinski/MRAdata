dataDir="data/img/"
lblDir="data/lbl/"
lblMIPDir="data/lbl_MIP/"

for f in paths.iterfiles(dataDir) do
  fn=paths.concat(dataDir,f)
  a=torch.load(fn)
  a=a:narrow(4,65,448-128):narrow(3,17,448-32)
  torch.save(fn,a:contiguous())
end

for f in paths.iterfiles(lblDir) do
  fn=paths.concat(lblDir,f)
  a=torch.load(fn)
  a=a:narrow(3,65,448-128):narrow(2,17,448-32)
  torch.save(fn,a:contiguous())
end

for f in paths.iterfiles(lblMIPDir) do
  fn=paths.concat(lblMIPDir,f)
  a=torch.load(fn)
  a1=a[1]:narrow(2,65,448-128):narrow(1,17,448-32)
  a2=a[2]:narrow(2,65,448-128)
  a3=a[3]:narrow(2,17,448-32)
  torch.save(fn,{a1:contiguous(), a2:contiguous(), a3:contiguous()})
end
